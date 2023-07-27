const mysql = require('mysql2/promise');


module.exports = {

    // returns all of the order items for this specific order along with the order details
    getOrder: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT `order`.*, `orderitem`.*, product.price, product.name, product.image FROM `order` JOIN `orderitem` ON `order`.orderId = `orderitem`.orderId JOIN `product` ON `orderitem`.productId = product.productId WHERE `order`.orderId = ?', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getAllOrders: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });
        console.log(id)

        const [results, fields] = await connection.execute('SELECT * from `order` WHERE customerId = ? ORDER BY orderId DESC', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getAllOrdersByShop: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });
        console.log(id)

        const [results, fields] = await connection.execute('SELECT `order`.*, SUM(`product`.price * `orderitem`.amount) as price, `user`.phoneNumber as customerNumber, `user`.name as customerName FROM `order` JOIN `orderitem` ON `order`.orderId = `orderitem`.orderId JOIN `product` ON `orderitem`.productId = product.productId JOIN `user` ON `order`.customerId = `user`.id WHERE `product`.shopId = ? GROUP BY `orderitem`.orderId ORDER BY orderId DESC', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getAllShopsRevenue: async () => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT SUM(`product`.price * `orderitem`.amount) as revenue FROM `order` JOIN `orderitem` ON `order`.orderId = `orderitem`.orderId JOIN `product` ON `orderitem`.productId = product.productId JOIN `user` ON `order`.customerId = `user`.id');
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getOrderStatus: async (orderId) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT `status` from `order` where `orderId` = ?', [orderId]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    updateOrderStatus: async (orderId, status) => {

        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        let results;

        const [rows, fields] = await connection.execute('UPDATE `order` set `status` = ? where `orderId` = ?', [status, orderId]);
        results = rows;


        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;
    },

    
    

    addOrder: async (order) => {

        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results
        // console.log(order)
        order.date = `2022-04-22 10:34:23`;
        const [rows, fields] = await connection.execute('INSERT INTO `order` (customerId, status, date) VALUES (?, ?, ?)', [order.customerId, order.status, order.date]);
        results = rows;


        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;
    },

    addOrderItem: async (orderItem) => {

        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results
        // console.log(orderItem)
        const [rows, fields] = await connection.execute('INSERT INTO `orderitem` (orderId, productId, amount) VALUES (?, ?, ?)', [orderItem.orderId, orderItem.productId, orderItem.amount]);
        results = rows;


        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;
    },

    // makePayment: async () => {

    // },



    // updateOrder: async (cartItem) => {
    //     const connection = await mysql.createConnection({
    //         host: "localhost",
    //         user: "root",
    //         password: "",
    //         database: "grocery",
    //     });

    //     var results

    //     const [rows, fields] = await connection.execute('UPDATE cartItem SET amount = ? WHERE cartItemId = ?', [cartItem.amount, cartItem.cartItemId]);
    //     results = rows;


    //     // console.log(fields)
    //     if (!results) {
    //         return null;
    //     }
    //     return results;

    // },

    // deleteOrder: async (id) => {
    //     const connection = await mysql.createConnection({
    //         host: "localhost",
    //         user: "root",
    //         password: "",
    //         database: "grocery",
    //     });

    //     const [results, fields] = await connection.execute('DELETE FROM `cartItem` WHERE `cartItemId` = ?', [id]);
    //     // console.log(results)
    //          connection.end();
    //     if (!results) {
    //         return null;
    //     }
    //     return results;
    // },

}