import RiskRatingsClient from '../riskRatingsClient.js';

/**
 * Example: Update Risk Scores
 * 
 * This example demonstrates how to submit signed extrinsics to update risk scores
 * for different partitions using the Risk Ratings pallet.
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
        
        // Example score updates
        const scoreUpdates = [
            { partition: 'test', score: 85 },
            { partition: 'prod', score: 92 },
            { partition: 'dev', score: 78 },
            { partition: 'staging', score: 88 }
        ];
        
        console.log('\n🚀 Starting score updates...');
        
        for (const update of scoreUpdates) {
            try {
                const txHash = await client.updateScore(alice, update.partition, update.score);
                console.log(`✅ Transaction hash: ${txHash}`);
                
                // Wait a bit between transactions to avoid nonce issues
                console.log('⏳ Waiting 6 seconds before next transaction...');
                await new Promise(resolve => setTimeout(resolve, 6000));
                
            } catch (error) {
                console.error(`❌ Failed to update ${update.partition}:`, error.message);
            }
        }
        
        console.log('\n🎯 All score updates completed!');
        
    } catch (error) {
        console.error('❌ Example failed:', error);
    } finally {
        await client.disconnect();
    }
}

// Run the example
console.log('📝 Risk Ratings - Update Scores Example');
console.log('=====================================');
updateScoresExample().catch(console.error);
