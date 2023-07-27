
const bcrypt = require('bcrypt');
const model = require('../models/User');


module.exports = {
    getCustomer: async (req, res) => {
        const data = await model.getCustomer(parseInt(req.params.id));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('The user with the given ID was not found.');
            return;
        }
        // if(data[0].address != null){
        //     data[0].addresss = JSON.parse(data[0].addresss);
        // }
        // else{
        //     data[0].address = '';
        // }
        
        var response = {
            id: data[0].id,
            name: data[0].name,
            address: data[0].address,
        }
        res.send(response);
    },

    getShop: async (req, res) => {
        const data = await model.getShop(parseInt(req.params.id));
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('The user with the given ID was not found.');
            return;
        }
        // if(data[0].address != null){
        //     data[0].addresss = JSON.parse(data[0].addresss);
        // }
        // else{
        //     data[0].address = '';
        // }

        var response = {
            id: data[0].id,
            name: data[0].name,
            description: data[0].description,
            shopStatus: data[0].shopStatus,
        }
        res.send(response);
    },

    register: async (req, res) => {

        const saltRounds = 10;
        bcrypt.genSalt(saltRounds, async function (err, salt) {
            bcrypt.hash(req.body.password, salt, async function (err, hash) {

                //type 0 = customer, type 1 = shop, type 2 = admin
                const user = {
                    email: req.body.email,
                    name: req.body.name,
                    password: hash,
                    type: req.body.type,
                    id: null
                }

                if (user.type == 1) {
                    // user.description = req.body.description;
                    // user.shopStatus = req.body.shopStatus;
                    // user.address = req.body.address;
                    user.description = "Placeholder description for now."
                    user.shopStatus = "pending"
                    user.address = "Meranti St.";
                }
                const data = await model.register(user);
                var response = {
                    id: data.insertId,
                    name: user.name,
                    type: user.type
                }
                res.status(201).send(response);
            });
        });
        //

    },

    login: async (req, res) => {
        // console.log(req)
        // Filter user from the users array by username and password
        const email = req.body.email;
        const password = req.body.password;
        const data = await model.login(email);

        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('Incorrect user information');
            return;
        }

        bcrypt.compare(password, data[0].password, function (err, result) {
            if (err) {
                console.log(err);
            }
            if (result) {
                var user = {
                    id: data[0].id,
                    name: data[0].name,
                    type: data[0].type
                }
                res.status(200).json(
                    user
                );
            } else {
                res.status(404).send('Failed to login');
            }
        });

    },

    updateUser: async (req, res) => {

        const saltRounds = 10;
        console.log(req.body);
        bcrypt.genSalt(saltRounds, async function (err, salt) {
            bcrypt.hash(req.body.password, salt, async function (err, hash) {
                const user = {
                    password: hash,
                    name: req.body.name,
                    address: req.body.address,
                    phoneNumber: req.body.phoneNumber,
                    description: req.body.description,
                    id: req.params.id,
                    type: req.body.type,
                }

                const data = await model.updateUser(user);
                response = "Successfully updated user."
                res.status(201).send(response);
            });
        });

    },


    updateUserAdmin: async (req, res) => {
        shopStatus = req.body.newStatus;
        const data = await model.updateUserAdmin(shopStatus, req.params.id);
        console.log(data);
        if (data.affectedRows == 0) {
            res.status(404).send('Shop not found');
            return;
        }
        res.send("Shop status updated successfully");
    },

    openCloseShop: async (req, res) => {
        shopStatus = req.body.newStatus;
        const data = await model.openCloseShop(shopStatus, req.params.id);
        console.log(data);
        if (data.affectedRows == 0) {
            res.status(404).send('Shop not found');
            return;
        }
        res.send("Shop status updated successfully");
    },

    deleteUser: async (req, res) => {
        const data = await model.deleteUser(parseInt(req.params.id));
        console.log(data);
        if (data.affectedRows == 0) {
            res.status(404).send('User not found');
            return;
        }
        res.send("User deleted successfully");
    },

    getAllShops: async (req, res) => {
        const data = await model.getAllShops();
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No shops were found');
            return;
        }
        var response = [];

        for (var i = 0; i < data.length; i++) {
            if(data[i].shopStatus != "active"){
                continue;
            }
            // data[i].addresss = JSON.parse(data[i].addresss);
            response.push({
                id: data[i].id,
                name: data[i].name,
                description: data[i].description
            })
        }

        res.send(response);
    },

    getAllShopsAdmin: async (req, res) => {
        const data = await model.getAllShops();
        if (!data || Object.keys(data).length === 0) {
            res.status(404).send('No shops were found');
            return;
        }
        var response = [];

        for (var i = 0; i < data.length; i++) {
            // data[i].addresss = JSON.parse(data[i].addresss);
            response.push({
                id: data[i].id,
                name: data[i].name,
                description: data[i].description,
                shopStatus: data[i].shopStatus
            })
        }

        res.send(response);
    },

}