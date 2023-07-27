const express = require("express");
const router = express.Router();

const controller = require("../controllers/Product");

router.get('/shop/:shopId', controller.getAllProducts);
router.put('/:id', controller.updateProduct);
router.delete('/:id', controller.deleteProduct);
router.post('/', controller.addProduct);

router.get('/shop/:shopId/:id', controller.getProduct);

module.exports = router;