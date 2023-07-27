const mysql = require('mysql2/promise');


module.exports = {

    getCustomer: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT * FROM `user` WHERE `id` = ? AND `type` = 0', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getShop: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT * FROM `user` WHERE `id` = ? AND `type` = 1', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    register: async (user) => {

        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results
        console.log(user);

        if (user.type == 1) {
            const [rows, fields] = await connection.query('INSERT INTO user (email, password, name, type, address, description, shopStatus) VALUES (?, ?, ?, ?, ?, ?, ?)', [user.email, user.password, user.name, user.type, JSON.stringify(user.address), user.description, user.shopStatus]);
            results = rows;
        }
        else {
            const [rows, fields] = await connection.execute('INSERT INTO user (email, password, name, type) VALUES (?, ?, ?, ?)', [user.email, user.password, user.name, user.type]);
            results = rows;
        }

        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;
    },

    login: async (email) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT * FROM `user` WHERE `email` = ?', [email]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    updateUser: async (user) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        console.log(user)

        var results
        if (user.type == 1) {
            const [rows, fields] = await connection.execute('UPDATE `user` set password = ?, name = ?, phoneNumber = ?, description = ? where id = ?', [user.password, user.name, user.phoneNumber, user.description, user.id]);
            results = rows;
        }
        else {
            const [rows, fields] = await connection.execute('UPDATE `user` set `password` = ?, `name` = ?, phoneNumber = ?, `address` = ? where `id` = ?', [user.password, user.name, user.phoneNumber, JSON.stringify(user.address), user.id]);
            results = rows;
        }

        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;

    },

    updateUserAdmin: async (shopStatus, id) => {
        console.log(shopStatus)
        console.log(id)
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results

        const [rows, fields] = await connection.execute('UPDATE user SET shopStatus = ? where id = ?', [shopStatus, id]);
        results = rows;

        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;

    },

    openCloseShop: async (shopStatus, id) => {
        console.log(shopStatus)
        console.log(id)
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        var results
        var openStatusString = "active"
        var closedStatusString = "closed"

        const [rows, fields] = await connection.execute('UPDATE user SET shopStatus = ? where id = ? AND (shopStatus = ? or shopStatus = ?)', [shopStatus, id, openStatusString, closedStatusString]);
        results = rows;

        // console.log(fields)
        if (!results) {
            return null;
        }
        return results;

    },


    deleteUser: async (id) => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('DELETE FROM `user` WHERE `id` = ?', [id]);
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

    getAllShops: async () => {
        const connection = await mysql.createConnection({
           host: "db-mysql-sgp1-94191-do-user-14351837-0.b.db.ondigitalocean.com",
            user: "doadmin",
            password: "AVNS_VNd7F-JtcdTrmgqhqbC",
            database: "grocery",
port: 25060,
        });

        const [results, fields] = await connection.execute('SELECT * FROM `user` WHERE `type` = 1');
        // console.log(results)
        connection.end();
        if (!results) {
            return null;
        }
        return results;
    },

}