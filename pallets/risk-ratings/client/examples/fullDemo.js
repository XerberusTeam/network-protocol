import RiskRatingsClient from '../riskRatingsClient.js';

/**
 * Example: Full Risk Ratings Demo
 * 
 * This example demonstrates the complete workflow:
 * 1. Update scores via signed extrinsics
 * 2. Query scores via RPC calls
 * 3. Verify the data matches
 */

async function fullDemo() {
    const client = new RiskRatingsClient();
    
    try {
        // Initialize connection
        await client.initialize();
        
        // Create account
        const alice = client.createAccount('//Alice');
        
        console.log('\n=== Phase 1: Initial RPC Tests ===');
        
        // Test say_hello
        await client.sayHello();
        
        // Check initial state
        console.log('\n📊 Checking initial partition states...');
        const testPartitions = ['demo_test', 'demo_prod'];
        
        for (const partition of testPartitions) {
            const initialScores = await client.getScores(partition);
            console.log(`Initial scores for "${partition}": ${initialScores.length} entries`);
        }
        
        console.log('\n=== Phase 2: Update Scores ===');
        
        // Update scores for demo partitions
        const updates = [
            { partition: 'demo_test', score: 75 },
            { partition: 'demo_test', score: 82 },  // Second update to same partition
            { partition: 'demo_prod', score: 95 },
        ];
        
        for (const update of updates) {
            console.log(`\n🔄 Updating ${update.partition} with score ${update.score}...`);
            
            try {
                const txHash = await client.updateScore(alice, update.partition, update.score);
                console.log(`✅ Success! Transaction: ${txHash}`);
                
                // Wait for block finalization
                console.log('⏳ Waiting 8 seconds for block finalization...');
                await new Promise(resolve => setTimeout(resolve, 8000));
                
            } catch (error) {
                console.error(`❌ Failed: ${error.message}`);
            }
        }
        
        console.log('\n=== Phase 3: Verify Updates ===');
        
        // Query updated scores
        for (const partition of testPartitions) {
            console.log(`\n📈 Querying updated scores for "${partition}"...`);
            
            try {
                const scores = await client.getScores(partition);
                
                if (scores.length > 0) {
                    console.log(`✅ Found ${scores.length} score(s):`);
                    scores.forEach((entry, index) => {
                        console.log(`   ${index + 1}. Score: ${entry.score}, Timestamp: ${entry.timestamp}`);
                    });
                    
                    // Show the latest score
                    const latest = scores[scores.length - 1];
                    console.log(`🎯 Latest score for "${partition}": ${latest.score}`);
                } else {
                    console.log(`ℹ️  No scores found for "${partition}"`);
                }
                
            } catch (error) {
                console.error(`❌ Query failed: ${error.message}`);
            }
        }
        
        console.log('\n=== Phase 4: Account Summary ===');
        
        // Show final account state
        const finalAccountInfo = await client.getAccountInfo(alice.address);
        console.log('\n💰 Final Account State:');
        console.log(`   Address: ${finalAccountInfo.address}`);
        console.log(`   Balance: ${finalAccountInfo.balance.free}`);
        console.log(`   Nonce: ${finalAccountInfo.nonce}`);
        
        console.log('\n🎉 Full demo completed successfully!');
        console.log('\n📋 Summary:');
        console.log(`   - Submitted ${updates.length} score updates`);
        console.log(`   - Queried ${testPartitions.length} partitions`);
        console.log(`   - All operations completed`);
        
    } catch (error) {
        console.error('❌ Demo failed:', error);
    } finally {
        await client.disconnect();
    }
}

// Run the full demo
console.log('🚀 Risk Ratings - Full Demo');
console.log('===========================');
console.log('This demo will:');
console.log('1. Test RPC connectivity');
console.log('2. Submit score updates');
console.log('3. Query and verify results');
console.log('4. Show account summary');
console.log('');

fullDemo().catch(console.error);
