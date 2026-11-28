package vn.order_tracking.entity;

import jakarta.persistence.OptimisticLockException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import vn.order_tracking.entity.enums.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.function.Consumer;

import static org.junit.jupiter.api.Assertions.*;

class EntityPersistenceTest {
    private static SessionFactory factory;

    @BeforeAll
    static void buildAllMappings() {
        Configuration configuration = new Configuration()
                .setProperty("hibernate.connection.driver_class", "org.h2.Driver")
                .setProperty("hibernate.connection.url", "jdbc:h2:mem:entities;MODE=MySQL;DB_CLOSE_DELAY=-1")
                .setProperty("hibernate.hbm2ddl.auto", "create-drop")
                .setProperty("hibernate.hbm2ddl.halt_on_error", "true")
                .setProperty("hibernate.jdbc.time_zone", "UTC");
        for (Class<?> entity : List.of(AuditLogs.class, Carriers.class, CartItems.class, Carts.class,
                DeliveryAttempts.class, Discounts.class, InvalidatedTokens.class, Inventories.class,
                Notifications.class, OrderDiscounts.class, OrderItems.class, Orders.class,
                PasswordResetTokens.class, Payments.class, PaymentTypes.class, Permissions.class,
                ProductImages.class, Products.class, ProductVariants.class, Role.class,
                RolePermissions.class, Shipments.class, TrackingLogs.class, User.class,
                UserAddress.class, UserRole.class)) {
            configuration.addAnnotatedClass(entity);
        }
        factory = configuration.buildSessionFactory();
        assertEquals(26, factory.getMetamodel().getEntities().size());
    }

    @AfterAll
    static void closeFactory() {
        if (factory != null) {
            factory.close();
        }
    }

    @ParameterizedTest
    @ValueSource(booleans = {false, true})
    void orphanRemovalDeletesAssignmentButPreservesUserAndRole(boolean removeFromRole) {
        User user = user();
        Role role = new Role();
        role.setCode("BUYER-" + UUID.randomUUID());
        role.setName("Buyer");
        inTransaction(session -> {
            session.persist(role);
            UserRole assignment = new UserRole();
            role.addUserRole(assignment);
            user.addUserRole(assignment);
            session.persist(user);
        });
        inTransaction(session -> {
            User loaded = session.find(User.class, user.getId());
            UserRole assignment = loaded.getUserRoles().getFirst();
            Role loadedRole = assignment.getRole();
            if (removeFromRole) {
                loadedRole.removeUserRole(assignment);
            } else {
                loaded.removeUserRole(assignment);
            }
            assertTrue(loaded.getUserRoles().isEmpty());
            assertTrue(loadedRole.getUserRoles().isEmpty());
            session.flush();
            session.clear();
            assertNull(session.find(UserRole.class, assignment.getId()));
            assertNotNull(session.find(User.class, user.getId()));
            assertNotNull(session.find(Role.class, role.getId()));
        });
    }

    @Test
    void inventoryRejectsConcurrentLostUpdate() {
        Inventories inventory = new Inventories();
        inTransaction(session -> {
            ProductVariants variant = persistVariant(session);
            inventory.setProductVariant(variant);
            inventory.setQuantityOnHand(10);
            session.persist(inventory);
        });
        try (Session first = factory.openSession(); Session second = factory.openSession()) {
            first.beginTransaction();
            second.beginTransaction();
            Inventories a = first.find(Inventories.class, inventory.getId());
            Inventories b = second.find(Inventories.class, inventory.getId());
            a.setQuantityReserved(1);
            first.getTransaction().commit();
            b.setQuantityReserved(2);
            assertThrows(OptimisticLockException.class, second::flush);
            second.getTransaction().rollback();
        }
    }

    @Test
    void allEntityTypesPersistAndReloadUsingTheirMappedColumns() {
        inTransaction(session -> {
            User user = user();
            session.persist(user);
            Role role = new Role();
            role.setCode("SELLER");
            role.setName("Seller");
            session.persist(role);
            Permissions permission = new Permissions();
            permission.setCode("ORDER_READ");
            permission.setName("Read order");
            session.persist(permission);
            UserRole membership = new UserRole();
            role.addUserRole(membership);
            user.addUserRole(membership);
            RolePermissions grant = new RolePermissions();
            grant.setPermission(permission);
            role.addRolePermission(grant);
            UserAddress address = new UserAddress();
            address.setRecipientName("Buyer");
            address.setRecipientPhone("0900000000");
            address.setAddressLine("1 Test Street");
            address.setProvince("Ha Noi");
            user.addAddress(address);

            Products product = new Products();
            product.setSeller(user);
            product.setName("Product");
            ProductVariants variant = variant();
            product.addProductVariant(variant);
            ProductImages image = new ProductImages();
            image.setImageUrl("https://example.com/product.png");
            product.addProductImage(image);
            image.setProductVariant(variant);
            session.persist(product);
            Inventories inventory = new Inventories();
            inventory.setProductVariant(variant);
            session.persist(inventory);
            Carts cart = new Carts();
            cart.setUser(user);
            CartItems cartItem = new CartItems();
            cartItem.setProductVariant(variant);
            cartItem.setQuantity(1);
            cart.addCartItem(cartItem);
            session.persist(cart);

            Discounts discount = new Discounts();
            discount.setCode("SAVE10");
            discount.setName("Save ten");
            discount.setDiscountType(DiscountType.FIXED);
            discount.setDiscountValue(BigDecimal.TEN);
            discount.setStartsAt(Instant.now());
            discount.setEndsAt(Instant.now().plusSeconds(3600));
            session.persist(discount);
            PaymentTypes paymentType = new PaymentTypes();
            paymentType.setCode("COD");
            paymentType.setName("Cash");
            session.persist(paymentType);
            Carriers carrier = new Carriers();
            carrier.setCode("TEST");
            carrier.setName("Test carrier");
            session.persist(carrier);

            Orders order = new Orders();
            order.setOrderNumber("TEST-" + UUID.randomUUID());
            order.setBuyer(user);
            order.setSeller(user);
            order.setSubtotal(new BigDecimal("100"));
            order.setDiscountTotal(BigDecimal.TEN);
            order.setGrandTotal(new BigDecimal("90"));
            order.setRecipientName("Buyer");
            order.setRecipientPhone("0900000000");
            order.setShippingAddressLine("1 Test Street");
            order.setShippingProvince("Ha Noi");
            OrderItems item = new OrderItems();
            item.setProductVariant(variant);
            item.setProductName(product.getName());
            item.setSku(variant.getSku());
            item.setQuantity(1);
            item.setUnitPrice(variant.getPrice());
            item.setWeightGrams(variant.getWeightGrams());
            order.addOrderItem(item);
            OrderDiscounts applied = new OrderDiscounts();
            applied.setDiscount(discount);
            applied.setDiscountCode(discount.getCode());
            applied.setDiscountType(discount.getDiscountType());
            applied.setDiscountValue(discount.getDiscountValue());
            applied.setDiscountAmount(BigDecimal.TEN);
            order.addOrderDiscount(applied);
            Payments payment = new Payments();
            payment.setPaymentType(paymentType);
            payment.setPaymentReference("PAY-1");
            payment.setProviderTransactionId("provider/non-uuid/123");
            payment.setIdempotencyKey("payment-1");
            payment.setAmount(order.getGrandTotal());
            order.addPayment(payment);
            Shipments shipment = new Shipments();
            shipment.setCarrier(carrier);
            shipment.setTrackingNumber("TRACK-1");
            shipment.setWeightGrams(variant.getWeightGrams());
            order.addShipment(shipment);
            TrackingLogs log = new TrackingLogs();
            log.setToStatus(ShipmentStatus.PENDING);
            log.setSource(TrackingSource.SYSTEM);
            log.setExternalEventId("carrier/event/123");
            shipment.addTrackingLog(log);
            DeliveryAttempts attempt = new DeliveryAttempts();
            attempt.setAttemptNumber(1);
            attempt.setShipper(user);
            attempt.setAttemptedAt(Instant.now());
            attempt.setResult(DeliveryAttemptResult.FAILED);
            attempt.setFailureReason("Recipient unavailable");
            shipment.addDeliveryAttempt(attempt);
            session.persist(order);

            Notifications notification = new Notifications();
            notification.setOrder(order);
            notification.setTrackingLog(log);
            notification.setEventKey("event-1");
            notification.setChannel(NotificationChannel.EMAIL);
            notification.setRecipient("buyer@example.com");
            notification.setContent("Order created");
            session.persist(notification);
            AuditLogs audit = new AuditLogs();
            audit.setActor(user);
            audit.setAction("CREATE");
            audit.setEntityType("Orders");
            audit.setEntityId(order.getId());
            audit.setNewValues("{\"status\":\"PENDING\"}");
            session.persist(audit);
            InvalidatedTokens denied = new InvalidatedTokens();
            denied.setUser(user);
            denied.setTokenHash("a".repeat(64));
            denied.setExpiresAt(Instant.now().plusSeconds(3600));
            session.persist(denied);
            PasswordResetTokens reset = new PasswordResetTokens();
            reset.setUser(user);
            reset.setTokenHash("b".repeat(64));
            reset.setExpiresAt(Instant.now().plusSeconds(3600));
            session.persist(reset);
            session.flush();
            List<BaseEntity> entities = List.of(user, role, permission, membership, grant, address,
                    product, variant, image, inventory, cart, cartItem, discount, paymentType,
                    carrier, order, item, applied, payment, shipment, log, attempt,
                    notification, audit, denied, reset);
            for (BaseEntity entity : entities) {
                assertNotNull(entity.getCreatedAt(), entity.getClass().getSimpleName());
                assertNotNull(entity.getUpdatedAt(), entity.getClass().getSimpleName());
            }
            session.clear();
            assertEquals("provider/non-uuid/123", session.find(Payments.class, payment.getId()).getProviderTransactionId());
            assertEquals("carrier/event/123", session.find(TrackingLogs.class, log.getId()).getExternalEventId());
            Orders loadedOrder = session.find(Orders.class, order.getId());
            assertEquals(1, loadedOrder.getOrderItems().size());
            assertSame(loadedOrder, loadedOrder.getOrderItems().getFirst().getOrder());
            assertNotNull(loadedOrder.getPlacedAt());
            assertNotNull(session.find(Notifications.class, notification.getId()).getNextRetryAt());
            assertEquals(user.getId(), session.find(User.class, user.getId()).getId());
            assertEquals(audit.getNewValues(), session.find(AuditLogs.class, audit.getId()).getNewValues());
        });
    }

    private static User user() {
        User user = new User();
        user.setEmail(UUID.randomUUID() + "@example.com");
        user.setUsername(UUID.randomUUID().toString());
        user.setPasswordHash("test-hash");
        user.setFullName("Test user");
        return user;
    }

    private static ProductVariants variant() {
        ProductVariants variant = new ProductVariants();
        variant.setSku(UUID.randomUUID().toString());
        variant.setPrice(new BigDecimal("100"));
        variant.setWeightGrams(new BigDecimal("250"));
        return variant;
    }

    private static ProductVariants persistVariant(Session session) {
        User seller = user();
        session.persist(seller);
        Products product = new Products();
        product.setSeller(seller);
        product.setName("Product");
        ProductVariants variant = variant();
        product.addProductVariant(variant);
        session.persist(product);
        return variant;
    }

    private static void inTransaction(Consumer<Session> work) {
        try (Session session = factory.openSession()) {
            session.beginTransaction();
            try {
                work.accept(session);
                session.getTransaction().commit();
            } catch (RuntimeException | Error failure) {
                session.getTransaction().rollback();
                throw failure;
            }
        }
    }
}
