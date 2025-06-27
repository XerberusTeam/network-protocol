import { ApiPromise, WsProvider } from '@polkadot/api';
import { Vec, Struct, u32 } from '@polkadot/types';
import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady } from '@polkadot/util-crypto';

/**
 * Risk Ratings Pallet Client
 * 
 * Provides methods to interact with the Risk Ratings pallet:
 * - Submit signed extrinsics to update scores
 * - Query scores via RPC calls
 * - Decode SCALE-encoded responses
 */
class RiskRatingsClient {
    constructor(nodeUrl = 'ws://127.0.0.1:9944') {
        this.nodeUrl = nodeUrl;
        this.api = null;
        this.keyring = null;
        this.isInitialized = false;
    }

    /**
     * Initialize the client connection and keyring
     */
    async initialize() {
        if (this.isInitialized) return;

        console.log(`🔗 Connecting to ${this.nodeUrl}...`);
        
        // Wait for crypto to be ready
        await cryptoWaitReady();
        
        // Connect to the node
        const wsProvider = new WsProvider(this.nodeUrl);
        this.api = await ApiPromise.create({ provider: wsProvider });
        
        // Initialize keyring
        this.keyring = new Keyring({ type: 'sr25519' });
        
        // Log connection info
        const [chain, version, name] = await Promise.all([
            this.api.rpc.system.chain(),
            this.api.rpc.system.version(),
            this.api.rpc.system.name()
        ]);
        
        console.log('✅ Connected to Substrate node');
        console.log(`   Chain: ${chain}`);
        console.log(`   Version: ${version}`);
        console.log(`   Node: ${name}`);
        
        this.isInitialized = true;
    }

    /**
     * Create or import an account for signing transactions
     * @param {string} seed - Account seed (e.g., '//Alice', mnemonic, or private key)
     * @returns {KeyringPair} Account keypair
     */
    createAccount(seed = '//Alice') {
        if (!this.keyring) {
            throw new Error('Client not initialized. Call initialize() first.');
        }
        
        const account = this.keyring.addFromUri(seed);
        console.log(`👤 Account loaded: ${account.address}`);
        return account;
    }

    /**
     * Submit a signed extrinsic to update a risk score
     * @param {KeyringPair} account - Account to sign the transaction
     * @param {string} partition - Partition name (e.g., 'test', 'prod')
     * @param {number} score - Risk score value
     * @param {number} timestamp - Unix timestamp
     * @returns {Promise<string>} Transaction hash
     */
    async updateScore(account, partition, score, timestamp) {
        if (!this.api) {
            throw new Error('Client not initialized. Call initialize() first.');
        }

        console.log(`\n📝 Updating score for partition "${partition}" with score ${score}...`);
        console.log(`   Using account: ${account.address}`);

        try {
            // Create the extrinsic - Polkadot.js will handle the Vec<u8> conversion
            const extrinsic = this.api.tx.riskRatings.updateScore(partition, score, timestamp);
            
            // Get estimated fee
            const info = await extrinsic.paymentInfo(account);
            console.log(`💸 Estimated fee: ${info.partialFee.toHuman()}`);
            
            // Sign and send the transaction
            return new Promise((resolve, reject) => {
                let txHash = null;
                
                extrinsic.signAndSend(account, ({ status, events, dispatchError, txHash: hash }) => {
                    if (hash) txHash = hash.toHex();
                    
                    console.log(`📡 Transaction status: ${status.type}`);
                    
                    if (status.isInBlock) {
                        console.log(`✅ Included in block: ${status.asInBlock.toHex()}`);
                        
                        // Process events
                        let success = false;
                        events.forEach(({ event }) => {
                            console.log(`📋 Event: ${event.section}.${event.method}`);
                            
                            if (event.section === 'riskRatings' && event.method === 'ScoreUpdated') {
                                const [partition, score, timestamp, updater] = event.data;
                                console.log(`🎯 Score updated successfully!`);
                                console.log(`   Partition: ${new TextDecoder().decode(partition)}`);
                                console.log(`   Score: ${score}`);
                                console.log(`   Timestamp: ${timestamp}`);
                                console.log(`   Updater: ${updater}`);
                                success = true;
                            }
                            
                            if (event.section === 'system' && event.method === 'ExtrinsicFailed') {
                                console.log('❌ Extrinsic failed!');
                                if (dispatchError) {
                                    if (dispatchError.isModule) {
                                        const decoded = this.api.registry.findMetaError(dispatchError.asModule);
                                        console.log(`   Error: ${decoded.section}.${decoded.name}`);
                                        console.log(`   Details: ${decoded.docs.join(' ')}`);
                                    } else {
                                        console.log(`   Error: ${dispatchError.toString()}`);
                                    }
                                }
                                reject(new Error('Extrinsic failed'));
                                return;
                            }
                        });
                        
                        if (success) {
                            resolve(txHash);
                        }
                    } else if (status.isFinalized) {
                        console.log(`🎯 Finalized in block: ${status.asFinalized.toHex()}`);
                    } else if (status.isDropped || status.isInvalid || status.isUsurped) {
                        console.log(`❌ Transaction ${status.type}`);
                        reject(new Error(`Transaction ${status.type}`));
                    }
                });
            });
            
        } catch (error) {
            console.error('❌ Error updating score:', error);
            throw error;
        }
    }

    /**
     * Call the say_hello RPC method
     * @returns {Promise<string>} Hello message from the pallet
     */
    async sayHello() {
        if (!this.api) {
            throw new Error('Client not initialized. Call initialize() first.');
        }

        console.log('\n👋 Calling say_hello RPC...');
        
        try {
            // Call the runtime API using state_call
            const result = await this.api.rpc.state.call('RiskRatingApi_say_hello', '0x');
            
            // Decode the result as Vec<u8> and convert to string
            const decoded = this.api.createType('Vec<u8>', result);
            const message = decoded.toUtf8();
            
            console.log(`📢 Response: "${message}"`);
            return message;
        } catch (error) {
            console.error('❌ Error calling say_hello:', error);
            throw error;
        }
    }

    /**
     * Get scores for a specific partition via RPC
     * @param {string} partition - Partition name to query
     * @returns {Promise<Array>} Array of score entries
     */
    async getScores(partition) {
        if (!this.api) {
            throw new Error('Client not initialized. Call initialize() first.');
        }

        console.log(`\n📊 Getting scores for partition "${partition}"...`);

        try {
            // Use Polkadot.js API to properly SCALE encode Vec<u8> with length prefix
            const partitionBytes = Array.from(new TextEncoder().encode(partition));
            const vecU8Type = this.api.createType('Vec<u8>', partitionBytes);
            const encodedPartition = vecU8Type.toU8a(); // Get raw bytes
            const encodedHex = '0x' + Array.from(encodedPartition).map(b => b.toString(16).padStart(2, '0')).join('');

            console.log(`🔍 Partition: "${partition}"`);
            console.log(`🔍 Partition bytes: [${partitionBytes.join(', ')}]`);
            console.log(`🔍 SCALE encoded bytes: [${Array.from(encodedPartition).join(', ')}]`);
            console.log(`🔍 SCALE encoded hex: ${encodedHex}`);

            // Call the runtime API using state_call with properly SCALE encoded partition
            const result = await this.api.rpc.state.call('RiskRatingApi_get_scores', encodedHex);
            console.log(`📦 Raw result: ${result}`);

            // Define ScoreEntry structure and decode
            const ScoreEntry = Struct.with({
                score: u32,
                timestamp: u32
            });

            const VecScoreEntry = Vec.with(ScoreEntry);
            const decoded = new VecScoreEntry(this.api.registry, result);
            const scores = decoded.toJSON();

            console.log(`📈 Scores for "${partition}":`, scores);

            if (scores.length > 0) {
                decoded.forEach((entry, index) => {
                    console.log(`   Entry ${index}: score=${entry.score.toNumber()}, timestamp=${entry.timestamp.toNumber()}`);
                });
            } else {
                console.log(`   No scores found for "${partition}"`);
            }

            return scores;
        } catch (error) {
            console.error(`❌ Error getting scores for "${partition}":`, error);
            throw error;
        }
    }

    /**
     * Decode a hex-encoded SCALE response manually
     * @param {string} hexResponse - Hex-encoded response (e.g., "0x040a0000000c000000")
     * @returns {Array} Decoded score entries
     */
    decodeHexResponse(hexResponse) {
        if (!this.api) {
            throw new Error('Client not initialized. Call initialize() first.');
        }

        console.log(`\n🔍 Decoding hex response: ${hexResponse}`);
        
        try {
            // Define ScoreEntry structure
            const ScoreEntry = Struct.with({
                score: u32,
                timestamp: u32
            });
            
            // Create Vec type and decode
            const VecScoreEntry = Vec.with(ScoreEntry);
            const decoded = new VecScoreEntry(this.api.registry, hexResponse);
            const scores = decoded.toJSON();
            
            console.log('📊 Decoded scores:', scores);
            decoded.forEach((entry, index) => {
                console.log(`   Entry ${index}: score=${entry.score.toNumber()}, timestamp=${entry.timestamp.toNumber()}`);
            });
            
            return scores;
        } catch (error) {
            console.error('❌ Error decoding hex response:', error);
            throw error;
        }
    }

    /**
     * Get account information
     * @param {string} address - Account address
     * @returns {Promise<Object>} Account info including balance and nonce
     */
    async getAccountInfo(address) {
        if (!this.api) {
            throw new Error('Client not initialized. Call initialize() first.');
        }

        const { nonce, data: balance } = await this.api.query.system.account(address);
        return {
            address,
            nonce: nonce.toNumber(),
            balance: {
                free: balance.free.toHuman(),
                reserved: balance.reserved.toHuman(),
                frozen: balance.frozen.toHuman()
            }
        };
    }

    /**
     * Disconnect from the node
     */
    async disconnect() {
        if (this.api) {
            await this.api.disconnect();
            console.log('👋 Disconnected from node');
            this.isInitialized = false;
        }
    }
}

export default RiskRatingsClient;
