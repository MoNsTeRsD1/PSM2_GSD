const express = require("express");
const router = express.Router();

const controller = require("../controllers/Order");

// id here is userId
router.get('/all/:id', controller.getAllOrders);
router.get('/all/shop/:id', controller.getAllOrdersByShop);

// When adding the logic to get the items for each ordersByShop, make sure it you are checking that you only show the orderItems where the products belongs to this shop (orders can contain items from different shops, the previous function accounts for this but dont forget it in newer ones)

// router.put('/:id', controller.updateOrder);

router.get('/adminRevenue', controller.getRevenue);

// id here is orderId
router.get('/:id', controller.getOrder);

// router.delete('/:id', controller.cancelOrder);
router.post('/', controller.createOrder);

router.put('/:id', controller.updateOrderStatus);

module.exports = router;