const express = require("express");
const router = express.Router();

const controller = require("../controllers/Cart");

router.get('/user/:id', controller.getAllCartItems);
router.get('/:id', controller.getCartItem);
router.post('/', controller.addCartItem);
router.put('/:id', controller.updateCartItem);
router.delete('/:id', controller.deleteCartItem);


module.exports = router;