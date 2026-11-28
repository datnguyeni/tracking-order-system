package vn.order_tracking.entity;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EntityRelationshipsTest {
    @Test
    void roleAssignmentSynchronizesBothParentsAndCannotBeReusedAfterRemoval() {
        User user = new User();
        Role role = new Role();
        UserRole assignment = new UserRole();
        user.addUserRole(assignment);
        role.addUserRole(assignment);
        user.addUserRole(assignment);

        assertSame(user, assignment.getUser());
        assertSame(role, assignment.getRole());
        assertEquals(1, user.getUserRoles().size());
        assertEquals(1, role.getUserRoles().size());
        assertThrows(UnsupportedOperationException.class, () -> user.getUserRoles().clear());
        assertThrows(IllegalStateException.class, () -> new User().addUserRole(assignment));
        assertSame(user, assignment.getUser());

        new User().removeUserRole(assignment);
        assertSame(user, assignment.getUser());
        role.removeUserRole(assignment);
        assertNull(assignment.getUser());
        assertNull(assignment.getRole());
        assertTrue(user.getUserRoles().isEmpty());
        assertTrue(role.getUserRoles().isEmpty());
        assertThrows(IllegalStateException.class, () -> user.addUserRole(assignment));
    }

    @Test
    void owningSideSetterAlsoMaintainsCollectionAndOrphanLifecycle() {
        Carts cart = new Carts();
        CartItems item = new CartItems();
        item.setCart(cart);
        assertEquals(java.util.List.of(item), cart.getCartItems());
        cart.addCartItem(null);
        cart.removeCartItem(null);
        new Carts().removeCartItem(item);
        assertSame(cart, item.getCart());
        cart.removeCartItem(item);
        assertNull(item.getCart());
        assertTrue(cart.getCartItems().isEmpty());
        assertThrows(IllegalStateException.class, () -> new Carts().addCartItem(item));
    }

    @Test
    void historicalChildrenCannotMoveOrBeDetached() {
        Orders order = new Orders();
        OrderItems item = new OrderItems();
        order.addOrderItem(item);
        order.addOrderItem(item);
        assertEquals(1, order.getOrderItems().size());
        assertThrows(IllegalStateException.class, () -> new Orders().addOrderItem(item));
        assertThrows(IllegalStateException.class, () -> item.setOrder(null));
        assertSame(order, item.getOrder());
        assertThrows(UnsupportedOperationException.class, () -> order.getOrderItems().clear());

        Shipments shipment = new Shipments();
        TrackingLogs log = new TrackingLogs();
        shipment.addTrackingLog(log);
        assertThrows(IllegalStateException.class, () -> log.setShipment(null));
        assertThrows(IllegalStateException.class, () -> new Shipments().addTrackingLog(log));
        assertEquals(java.util.List.of(log), shipment.getTrackingLogs());
    }

    @Test
    void productImageRejectsVariantOfAnotherProductWithoutChangingState() {
        Products product = new Products();
        ProductVariants variant = new ProductVariants();
        product.addProductVariant(variant);
        ProductImages image = new ProductImages();
        product.addProductImage(image);
        image.setProductVariant(variant);

        Products otherProduct = new Products();
        ProductVariants otherVariant = new ProductVariants();
        otherProduct.addProductVariant(otherVariant);
        assertThrows(IllegalArgumentException.class, () -> image.setProductVariant(otherVariant));
        assertSame(variant, image.getProductVariant());
        assertSame(product, image.getProduct());
    }

    @Test
    void addressesAndPermissionAssignmentsAreEncapsulated() {
        User user = new User();
        UserAddress address = new UserAddress();
        address.setUser(user);
        assertEquals(java.util.List.of(address), user.getAddresses());
        user.removeAddress(address);
        assertNull(address.getUser());

        Role role = new Role();
        Permissions permission = new Permissions();
        RolePermissions assignment = new RolePermissions();
        assignment.setPermission(permission);
        role.addRolePermission(assignment);
        role.removeRolePermission(assignment);
        assertNull(assignment.getRole());
        assertSame(permission, assignment.getPermission());
        assertFalse(permission.isDeleted());
    }
}
