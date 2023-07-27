const express = require('express');
var cors = require('cors')
const app = express();
app.use(express.json({ limit: '1gb' }));

app.use(cors({
    origin: '*'
}));

const userRoute = require("./routes/User");
const productRoute = require("./routes/Product")
const orderRoute = require("./routes/Order")
const cartRoute = require("./routes/Cart")

app.use('/users', userRoute);
app.use('/products', productRoute);
app.use('/orders', orderRoute);
app.use('/cart', cartRoute);

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`listening on port ${port}...`)
})