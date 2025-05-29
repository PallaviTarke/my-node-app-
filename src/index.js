const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello, World! Pallavi here');
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 8080;

// MongoDB connection URI from environment variable
const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';  // Fallback for local testing
const client = new MongoClient(uri);

async function run() {
  try {
    // Connect to MongoDB
    await client.connect();
    console.log('Connected to MongoDB');

    // Use a database and collection
    const db = client.db('mydb');
    const collection = db.collection('mycollection');

    // Example: Insert a document
    await collection.insertOne({ message: 'Hello from MongoDB!' });
    console.log('Inserted document into MongoDB');

    // Example route to fetch data
    app.get('/', async (req, res) => {
      const docs = await collection.find({}).toArray();
      res.json(docs);
    });
  } catch (err) {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1);  // Exit if MongoDB connection fails
  }
}

run().catch(console.dir);

app.listen(port, () => {
  console.log(`Node.js app listening on port ${port}`);
});

// Ensure MongoDB connection is closed when the app shuts down
process.on('SIGINT', async () => {
  await client.close();
  console.log('MongoDB connection closed');
  process.exit(0);
});
