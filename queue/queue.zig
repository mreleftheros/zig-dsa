const std = @import("std");

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const Node = struct { inner: T, next: ?*Node };
        gpa: std.mem.Allocator,
        start: ?*Node = null,
        end: ?*Node = null,

        pub fn init(gpa: std.mem.Allocator) Self {
            return Self{ .gpa = gpa };
        }

        pub fn enqueue(self: *Self, item: T) !void {
            const n = try self.gpa.create(Node);
            n.* = .{ .inner = item, .next = null };

            if (self.end) |end| {
                end.next = n;
            } else {
                self.start = n;
            }
            self.end = n;
        }

        pub fn dequeue(self: *Self) ?T {
            const start = self.start orelse return null;
            defer self.gpa.destroy(start);

            self.start = start.next;
            if (start.next == null) {
                self.end = null;
            }

            return start.inner;
        }
    };
}

test "test queue" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const al = gpa.allocator();

    var q = Queue(u8).init(al);

    // enqueue
    try q.enqueue(1);
    try std.testing.expect(q.start.?.inner == 1);
    try std.testing.expect(q.start.?.next == null);
    try std.testing.expect(q.end.?.inner == 1);
    try std.testing.expect(q.end.?.next == null);

    try q.enqueue(2);
    try std.testing.expect(q.start.?.inner == 1);
    try std.testing.expect(q.start.?.next != null);
    try std.testing.expect(q.end.?.inner == 2);
    try std.testing.expect(q.end.?.next == null);

    try q.enqueue(3);
    try std.testing.expect(q.start.?.inner == 1);
    try std.testing.expect(q.start.?.next != null);
    try std.testing.expect(q.end.?.inner == 3);
    try std.testing.expect(q.end.?.next == null);

    try std.testing.expect(q.start.?.next.?.next.?.inner == 3);

    // dequeue
    var n = q.dequeue();
    try std.testing.expect(n == 1);

    n = q.dequeue();
    try std.testing.expect(n == 2);

    n = q.dequeue();
    try std.testing.expect(n == 3);

    n = q.dequeue();
    try std.testing.expect(n == null);
}
