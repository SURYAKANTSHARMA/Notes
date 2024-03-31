 const mongoose = require('mongoose')
 const password = process.env.PASSWORD;
 const email = process.env.EMAIL;
 
 //const uri = 'mongodb+srv://${email}:${password}.mauoshz.mongodb.net/?retryWrites=true&w=majority';

// mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
mongoose.connect('mongodb+srv://suryakantsharma84:${password}@cluster0.mauoshz.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', { useNewUrlParser: true, useUnifiedTopology: true });
