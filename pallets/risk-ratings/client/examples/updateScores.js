import RiskRatingsClient from '../riskRatingsClient.js';

/**
 * Example: Update Risk Scores
 * 
 * This example demonstrates the proper Substrate ecosystem approach:
 * **PALLET**: Accepts i128 directly (like all major Substrate pallets)
 * **CLIENT**: Handles decimal string to i128 conversion with 10^18 scaling
 */

async function updateScoresExample() {
    const client = new RiskRatingsClient();
    
    try {
        // Initialize connection
        await client.initialize();
        
        // Create account (using Alice for demo - replace with your account)
        const alice = client.createAccount('//Alice');
        
        // Show account info
        const accountInfo = await client.getAccountInfo(alice.address);
        console.log('\n💰 Account Info:');
        console.log(`   Address: ${accountInfo.address}`);
        console.log(`   Balance: ${accountInfo.balance.free}`);
        console.log(`   Nonce: ${accountInfo.nonce}`);
        
        // Example score updates using i128 with 10^18 scaling
        const scoreUpdates = [
            { partition: 'test', score: '-8.5' },                    // Negative decimal
            { partition: 'prod', score: '33333333' },                // Large integer  
            { partition: 'dev', score: '100034234.8998989' },        // High precision decimal
            { partition: 'staging', score: '0.000000000000000001' }, // Very small decimal (18 places)
            { partition: 'negative_test', score: '-123.456' },       // Negative decimal
            { partition: 'negative_test', score: '-999999.999' },    // Large negative decimal
            { partition: 'negative_test', score: '-0.000001' },      // Small negative decimal
        ];
        
        console.log('\n🚀 Starting score updates with i128 implementation...');
        console.log('✅ PALLET: Accepts i128 directly (scaled by 10^18)');
        console.log('🔧 CLIENT: Handles decimal string to i128 conversion');
        
        for (const update of scoreUpdates) {
            try {
                // Generate current Unix timestamp (in seconds)
                const timestamp = Math.floor(Date.now() / 1000);
                
                // ✅ i128 IMPLEMENTATION:
                // - Client converts decimal string to i128 scaled by 10^18
                // - Pallet receives i128 parameter directly
                // - Same pattern used by pallet-balances, pallet-staking, etc.
                const txHash = await client.updateScore(alice, update.partition, update.score, timestamp);
                console.log(`✅ Updated ${update.partition} with score ${update.score} at timestamp ${timestamp}`);
                console.log(`   Transaction hash: ${txHash}`);
                
                // Wait a bit between transactions to avoid nonce issues
                console.log('⏳ Waiting 6 seconds before next transaction...');
                await new Promise(resolve => setTimeout(resolve, 6000));
                
            } catch (error) {
                console.error(`❌ Failed to update ${update.partition}:`, error.message);
            }
        }
        
        console.log('\n🎯 All score updates completed!');
        
        // Demonstrate built-in validation - client rejects invalid inputs
        console.log('\n🛡️ Demonstrating built-in validation...');
        const invalidInputs = ['RANDOM string', 'not-a-number', '∞', 'NaN', 'infinity'];
        
        for (const invalidScore of invalidInputs) {
            try {
                // This will fail at the client level when trying to convert to i128
                await client.updateScore(alice, 'test-validation', invalidScore, Math.floor(Date.now() / 1000));
                console.log(`❌ UNEXPECTED: "${invalidScore}" was accepted (this should not happen)`);
            } catch (error) {
                console.log(`✅ CORRECT: "${invalidScore}" was rejected - ${error.message}`);
            }
        }
        
        console.log('\n📚 KEY PRINCIPLES:');
        console.log('1. 🎯 PALLET LEVEL: Accept strongly-typed parameters (i128)');
        console.log('2. 🔧 CLIENT LEVEL: Handle user-friendly decimal string conversion');
        console.log('3. 🛡️ TYPE SAFETY: Rust enforces correctness at runtime');
        console.log('4. 🌍 ECOSYSTEM: Same pattern across all Substrate pallets');
        
        console.log('\n🏆 COMPARISON:');
        console.log('✅ THIS APPROACH (Standard):');
        console.log('   Pallet: pub fn update_score(..., score: i128, ...)');
        console.log('   Client: decimalToI128("-8.5") → "-8500000000000000000"');
        console.log('');
        console.log('❌ OVER-ENGINEERED (Anti-pattern):');
        console.log('   Pallet: pub fn update_score(..., score: Vec<u8>, ...) // String parsing');
        console.log('   Client: api.tx.riskRatings.updateScore(partition, score, timestamp)');
        console.log('');
        console.log('🌍 Same pattern as:');
        console.log('   - pallet-balances (accepts Balance type, client converts strings)');
        console.log('   - pallet-staking (accepts BalanceOf type, client converts strings)');
        console.log('   - All major Substrate ecosystem pallets');
        
    } catch (error) {
        console.error('❌ Example failed:', error);
    } finally {
        await client.disconnect();
    }
}

// Run the example
console.log('📝 Risk Ratings - i128 Implementation Example');
console.log('============================================');
updateScoresExample().catch(console.error);
