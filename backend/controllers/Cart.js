
const bcrypt = require('bcrypt');
const model = require('../models/CartItem');


module.exports = {
    getCartItem: async (req, res) => {
        const data = await model.getCartItem(parseInt(req.params.id));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('Product not found.');
            return;
        }

        
        res.send(data[0]);
    },

    addCartItem: async (req, res) => {


        //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        //modify this part to check userId in token and use it to add the product to the correct shop
        userId = req.body.userId;

        // console.log(req.body)

        const cartItem = {
            customerId: userId,
            productId: req.body.productId,
            amount: req.body.amount,
        }

        const data = await model.addCartItem(cartItem);
        var response = {
            id: data.insertId,
        }

        res.status(201).send(response);


    },

    updateCartItem: async (req, res) => {

        try {
            // //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        //check userId in token and use it to add the product to the correct shop
        userId = req.body.userId;

        // console.log(req.body);

        const cartItem = {
            cartItemId: req.params.id,
            amount: req.body.amount,
        }

        const data = await model.updateCartItem(cartItem);

        res.status(200).send("Successfully Updated Product.");
            
        } catch (error) {
            console.log(error);
        }

    },

    deleteCartItem: async (req, res) => {

        // //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        try {

            //modify this part to check userId in token and use it to add the product to the correct shop
            // userId = req.body.userId;
            
            const data = await model.deleteCartItem(parseInt(req.params.id));
            // console.log(data);
            if (data.affectedRows == 0) {
                res.status(404).send('Product not found');
                return;
            }
            res.send("Product deleted successfully");

        } catch (error) {
            console.log(error);
        }
    },

    getAllCartItems: async (req, res) => {

        //modify this part to check userId in token and use it to add the product to the correct shop
        userId = req.params.id;

        const data = await model.getAllCartItems(userId);
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        var response = [];

        for (var i = 0; i < data.length; i++) {
            response.push({
                name: data[i].name,
                cartItemId: data[i].cartItemId,
                productId: data[i].productId,
                amount: data[i].amount,
                price: data[i].price,
                image: JSON.parse(data[i].image),
                stock: data[i].stock,
            })
        }

        res.send(response);
    },

    getCartItemsForOrder: async (userId) => {

        const data = await model.getAllCartItems(userId);
        if (!data || Object.keys(data).length === 0) {
            return null;
        }
        var cartItems = [];

        for (var i = 0; i < data.length; i++) {
            cartItems.push({
                productId: data[i].productId,
                amount: data[i].amount,
            })
        }
        return cartItems;
    },

    clearCart: async (userId) => {

        // console.log(`clear cart for ${userId}`);

        const status = await model.clearCart(userId);

        return status;
    }

}
