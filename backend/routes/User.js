const express = require("express");
const router = express.Router();

const controller = require("../controllers/User");

router.get('/shops', controller.getAllShops);
router.get('/shopsAdmin', controller.getAllShopsAdmin);
router.put('/:id', controller.updateUser);
router.put('/shopStatus/:id', controller.openCloseShop);
router.put('/shops/:id', controller.updateUserAdmin);
router.get('/:id', controller.getCustomer);
router.get('/shops/:id', controller.getShop);
router.delete('/:id', controller.deleteUser);
router.post('/', controller.register);
router.post('/login', controller.login);

module.exports = router;