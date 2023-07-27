const mysql = require('mysql2/promise');


module.exports = {

    getCartItem: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT `cartitem`.*, product.price, product.name, product.image FROM `cartitem` JOIN `product` ON `cartitem`.productId = product.productId AND `cartItemId` = ?', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    addCartItem: async (cartItem) => {

        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results
        // console.log(cartItem)
        const [rows, fields] = await connection.execute('INSERT INTO `cartitem` (customerId, productId, amount) VALUES (?, ?, ?)', [cartItem.customerId, cartItem.productId, cartItem.amount]);
        results = rows;


        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;
    },

    updateCartItem: async (cartItem) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results

        const [rows, fields] = await connection.execute('UPDATE `cartitem` SET amount = ? WHERE cartItemId = ?', [cartItem.amount, cartItem.cartItemId]);
        results = rows;


        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;

    },

    deleteCartItem: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('DELETE FROM `cartitem` WHERE `cartItemId` = ?', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getAllCartItems: async (userId) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT `cartitem`.*, product.price, product.name, product.image, product.stock FROM `cartitem` JOIN `product` ON `cartitem`.productId = product.productId  AND `customerId` = ?', [userId]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        // console.log(results)
        return results;
    },

    clearCart: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('DELETE from `cartitem` WHERE `customerId` = ?', [userId]);
        connection.end();
        if (!results) {
            return false;
        }
        if(results.affectedRows > 0) {
            return true;
        }
        else {
            return false;
        }

        
    }

}