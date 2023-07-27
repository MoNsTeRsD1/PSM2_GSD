
const bcrypt = require('bcrypt');
const model = require('../models/Product');



module.exports = {
    getProduct: async (req, res) => {
        const data = await model.getProduct(parseInt(req.params.shopId), parseInt(req.params.id));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('Product not found.');
            return;
        }
        
        let response = {
            //image: JSON.parse(data[0].image)
        }
        // console.log(data[0])
        data[0].image = JSON.parse(data[0].image);
        res.send(data[0]);
    },

    addProduct: async (req, res) => {


        //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        //modify this part to check userId in token and use it to add the product to the correct shop
        shopId = req.body.shopId;

        const product = {
            name: req.body.name,
            image: req.body.image,
            price: req.body.price,
            shopId: shopId,
            stock: req.body.stock,
        }

        // console.log(product)

        const data = await model.addProduct(product);
        var response = {
            id: data.insertId,
        }

        res.status(201).send(response);


    },

    updateProduct: async (req, res) => {

        try {
            // //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        //check userId in token and use it to add the product to the correct shop
        shopId = req.body.shopId;

        // console.log(req.body);

        const product = {

            id: req.params.id,
            name: req.body.name,
            image: req.body.image,
            price: req.body.price,
            shopId: shopId,
            stock: req.body.stock,
        }

        const data = await model.updateProduct(product);

        res.status(200).send("Successfully Updated Product.");
            
        } catch (error) {
            console.log(error);
        }

    },

    updateStock: async (product) => {
        const data = await model.updateStock(product);
        return data;
    },

    deleteProduct: async (req, res) => {

        // //check if the user is a shop type user
        // if (user.type != 1) {
        //     return;
        // }

        try {

            //modify this part to check userId in token and use it to add the product to the correct shop
            shopId = req.body.shopId;
            
            const data = await model.deleteProduct(parseInt(req.params.id));
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

    getAllProducts: async (req, res) => {

        const data = await model.getAllProducts(parseInt(req.params.shopId));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No products were found');
            return;
        }
        var response = [];


        for (var i = 0; i < data.length; i++) {
            response.push({
                id: data[i].productId,
                name: data[i].name,
                description: ' ',
                price: data[i].price,
                image: JSON.parse(data[i].image),
                stock: data[i].stock
            })
        }

        res.send(response);
    },

}