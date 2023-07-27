
const bcrypt = require('bcrypt');
// const orderModel = require('../models/Order');
// const itemModel = require('../models/OrderItem');
const model = require('../models/Order');

const cartController = require('./Cart');
const productModel = require('./Product');

module.exports = {
    getOrder: async (req, res) => {
        const data = await model.getOrder(parseInt(req.params.id));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('Product not found.');
            return;
        }

        for (let i = 0; i < data.length; i++) {
            data[i].image = JSON.parse(data[i].image);

            var splitStatus = data[i].status.split('-');
            let status = splitStatus[0];
            let discount = splitStatus[1];
            let paymentMethod = splitStatus[2];


            if(paymentMethod == null){
                paymentMethod = 'cash'

            }
            
            if (discount == null) {
                discount = 0;
            }

            data[i].price = data[i].price * (1 - (discount / 100));
        }

        res.send(data);
    },

    createOrder: async (req, res) => {

        //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        //modify this part to check userId in token and use it to add the product to the correct shop
        let userId = req.body.userId
        let paymentMethod = req.body.paymentMethod
        let discount = req.body.discount;
        // let totalAmount = req.body.totalAmount

        // console.log(req.body)

        let cartItems = [];
        cartItems = await cartController.getCartItemsForOrder(userId);

        // console.log(cartItems);

        if (!cartItems || Object.keys(cartItems).length === 0) {
            res.status(404).send('No Products found in cart');
            return;
        }

        // create a new order and get the order id returned to you
        // order parts are as follows:
        // orderId => leave blank, return it from db after creating and use it for the next step
        // customerId => set it to the current user's id (get it from deciphered token later)
        // status => set it to pending and when payment is confirmed, set it to complete
        // date => set it to current date for now

        const currentDate = new Date();

        console.log(discount)
        let statusString = 'pending';
        // append discount to status string
        if (discount != 0) {
            statusString += `-${discount}`
        }
        else{
            statusString += `-0`
        }

        // append paymentMethod to status string
        if (paymentMethod != null) {
            statusString += `-${paymentMethod}`
        }
        else{
            statusString += `-cash`
        }

        let order = {
            customerId: userId,
            status: statusString,
            date: currentDate.toLocaleDateString("en-US")
        }

        const data = await model.addOrder(order);
        // const orderId = data.insertId;
        // const orderId = await data.insertId;



        // for each cart item
        cartItems.forEach(async (item) => {
            // create a new order item identical to this cart item
            // itemId / orderId / productId / amount
            let newItem = {
                orderId: data.insertId,
                productId: item.productId,
                amount: item.amount
            }

            // model.addOrderItem
            const orderItem = await model.addOrderItem(newItem)
            await productModel.updateStock(newItem);
            // console.log(orderItem)
        })

        // const data = await model.addCartItem(cartItem);

        var response = {
            id: data.insertId,
        }

        cartController.clearCart(userId);

        res.status(201).send(response);


    },

    // updateCartItem: async (req, res) => {

    //     try {
    //         // //check if the user is a shop type user
    //     // if (user.type != 1) {
    //     //     return;
    //     // }

    //     //check userId in token and use it to add the product to the correct shop
    //     userId = req.body.userId;

    //     // console.log(req.body);

    //     const cartItem = {
    //         cartItemId: req.params.id,
    //         amount: req.body.amount,
    //     }

    //     const data = await model.updateCartItem(cartItem);

    //     res.status(200).send("Successfully Updated Product.");

    //     } catch (error) {
    //         console.log(error);
    //     }

    // },

    // deleteCartItem: async (req, res) => {

    //     // //check if the user is a shop type user
    //     // if (user.type != 1) {
    //     //     return;
    //     // }

    //     try {

    //         //modify this part to check userId in token and use it to add the product to the correct shop
    //         // userId = req.body.userId;

    //         const data = await model.deleteCartItem(parseInt(req.params.id));
    //         // console.log(data);
    //         if (data.affectedRows == 0) {
    //             res.status(404).send('Product not found');
    //             return;
    //         }
    //         res.send("Product deleted successfully");

    //     } catch (error) {
    //         console.log(error);
    //     }
    // },


    // split status by '-'. status[0] will be the status, status[1] will be the discount amount status[2] will be the payment method
    getAllOrders: async (req, res) => {

        //modify this part to check userId in token and use it to add the product to the correct shop
        let userId = req.params.id;

        const data = await model.getAllOrders(userId);
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        console.log(data)

        var response = [];

        for (var i = 0; i < data.length; i++) {
            var splitStatus = data[i].status.split('-');
            let status = splitStatus[0];
            let discount = splitStatus[1];
            let paymentMethod = splitStatus[2];


            if(paymentMethod == null){
                paymentMethod = 'cash'

            }

            if (discount == null) {
                discount = 0;
            }

            let price = data[i].price * (1 - (discount / 100));

            
            response.push({
                orderId: data[i].orderId,
                status: status,
                date: data[i].date,
                discount: discount,
                paymentMethod: paymentMethod
            })
        }

        res.send(response);
    },

    updateOrderStatus: async (req, res) => {
        
        let orderId = req.params.id;
        let newStatus = req.body.newStatus;

        let oldStatusData = await model.getOrderStatus(orderId);

        // console.log(oldStatusData[0]);
        
        let splitStatus = oldStatusData[0].status.split('-');
            let oldStatus = splitStatus[0];
            let discount = splitStatus[1];
            let paymentMethod = splitStatus[2];

        let statusString = newStatus + '-' + discount + '-' + paymentMethod

        // console.log(statusString);

        const data = await model.updateOrderStatus(orderId, statusString);

        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        console.log(data)

        var response = 'Successfully updated order status.';

        res.send(response);
    },

    // split status by '-'. status[0] will be the status, status[1] will be the discount amount
    getAllOrdersByShop: async (req, res) => {

        //modify this part to check userId in token and use it to add the product to the correct shop
        let shopId = req.params.id;

        const data = await model.getAllOrdersByShop(shopId);
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        console.log(data)

        var response = [];

        for (let i = 0; i < data.length; i++) {
            let splitStatus = data[i].status.split('-');
            let status = splitStatus[0];
            let discount = splitStatus[1];
            let paymentMethod = splitStatus[2];

            if(paymentMethod == null){
                paymentMethod = 'cash on delivery'
            }
            else if (paymentMethod == 'cash'){
                paymentMethod = 'cash on delivery'
            }
            else if (paymentMethod == 'card'){
                paymentMethod = 'card payment'
            }

            if (discount == null) {
                discount = 0;
            }
            let commission = 5;

            let price = data[i].price * (1 - (discount / 100)); // reduce price by discount
            price = price * (1 - (commission / 100)); // reduce price by commission (5%)

            response.push({
                orderId: data[i].orderId,
                status: status,
                date: data[i].date,
                originalPrice: data[i].price,
                price: price,
                commission: commission,
                discount: discount,
                customerName: data[i].customerName,
                customerNumber: data[i].customerNumber,
                paymentMethod: paymentMethod,
            })
        }

        res.send(response);
    },

    getRevenue: async (req, res) => {

        const data = await model.getAllShopsRevenue();
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        console.log(data);

        let commission = 5;
        let totalRevenue = data[0].revenue;
        let adminRevenue = totalRevenue * (commission / 100); // reduce price by commission (5%)

        console.log(adminRevenue);

        let response = {
            'revenue': adminRevenue,
        }
        res.send(response)
    },

}