# alias t := test
default: (test dsa)

dsa := "queue"

test dsa:
    zig test ./queue/{{dsa}}.zig
