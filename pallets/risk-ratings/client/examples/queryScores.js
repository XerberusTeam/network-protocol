import RiskRatingsClient from '../riskRatingsClient.js';

/**
 * Example: Query Risk Scores
 * 
 * This example demonstrates how to query risk scores using RPC calls
 * to the Risk Ratings pallet.
 */

async function queryScoresExample() {
    const client = new RiskRatingsClient();
    
    try {
        // Initialize connection
        await client.initialize();
        
        // 1. Test the say_hello RPC method
        console.log('\n=== Testing say_hello RPC ===');
        const helloMessage = await client.sayHello();
        
        // 2. Query scores for different partitions
        console.log('\n=== Querying Partition Scores ===');
        const partitions = ['test', 'prod', 'dev', 'staging', 'nonexistent'];

        for (const partition of partitions) {
            try {
                const scores = await client.getScores(partition);

                if (scores.length > 0) {
                    console.log(`✅ Found ${scores.length} score(s) for "${partition}"`);
                    scores.forEach((score, index) => {
                        console.log(`   Score ${index + 1}: ${score.score} (timestamp: ${score.timestamp})`);
                    });
                } else {
                    console.log(`ℹ️  No scores found for "${partition}"`);
                }

            } catch (error) {
                console.error(`❌ Error querying "${partition}":`, error.message);
            }
        }
        
        // 3. Demonstrate manual hex decoding
        // console.log('\n=== Manual Hex Decoding ===');
        
        // // Example hex responses (you can replace these with actual responses from your pallet)
        // const hexResponses = [
        //     "0x040a0000000c000000",  // 1 entry: score=10, timestamp=12
        //     "0x080a0000000c0000000f00000010000000",  // 2 entries
        //     "0x00"  // Empty response
        // ];
        
        // for (const hex of hexResponses) {
        //     try {
        //         console.log(`\n🔍 Decoding: ${hex}`);
        //         const decoded = client.decodeHexResponse(hex);
        //         console.log(`   Result: ${decoded.length} entries`);
        //     } catch (error) {
        //         console.error(`❌ Failed to decode ${hex}:`, error.message);
        //     }
        // }
        
        // // 4. Show encoding examples for manual RPC calls
        // console.log('\n=== SCALE Encoding Examples ===');
        // console.log('For manual RPC calls with curl, use these encoded partition names:');

        const examplePartitions = ['test', 'prod', 'dev', 'staging'];
        for (const partition of examplePartitions) {
            const encoded = client.api.createType('Vec<u8>',
                Array.from(new TextEncoder().encode(partition))
            ).toHex();
            console.log(`   "${partition}" -> ${encoded}`);
        }

        console.log('\nExample curl command for "test" partition:');
        // console.log('curl -H "Content-Type: application/json" -d \'{\n' +
        //            '  "jsonrpc": "2.0",\n' +
        //            '  "method": "state_call",\n' +
        //            '  "params": ["RiskRatingApi_get_scores", "0x1074657374"],\n' +
        //            '  "id": 1\n' +
        //            '}\' http://127.0.0.1:9944');
        
    } catch (error) {
        console.error('❌ Example failed:', error);
    } finally {
        await client.disconnect();
    }
}

// Run the example
console.log('📊 Risk Ratings - Query Scores Example');
console.log('=====================================');
queryScoresExample().catch(console.error);
