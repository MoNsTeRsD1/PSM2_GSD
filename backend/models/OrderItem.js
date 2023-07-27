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
        if (user.type == 1) {
            const [rows, fields] = await connection.execute('INSERT INTO user (email, password, name, type, address, description, shopStatus) VALUES (?, ?, ?, ?, ?, ?, ?)', [user.email, user.password, user.name, user.type, user.address, user.description, user.shopStatus]);
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

        var results
        if (user.type == 1) {
            const [rows, fields] = await connection.execute('UPDATE user set email = ?, password = ?, name = ?, type = ?, address = ?, description = ?, shopStatus = ? where id = ?', [user.email, user.password, user.name, user.type, user.address, user.description, user.shopStatus]);
            results = rows;
        }
        else {

            const [rows, fields] = await connection.execute('UPDATE user set email = ?, password = ?, name = ?, type = ?, address = ?, description = ?, shopStatus = ? where id = ?', [user.email, user.password, user.name, user.type, user.address, user.description, user.shopStatus]);
            results = rows;
        }

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