import os
import select
import sys
import termios
import time
import tty

fd = sys.stdin.fileno()
out = sys.stdout.fileno()
old = termios.tcgetattr(fd)
data = bytearray()

print("switch away, then return with alt+h while holding h", flush=True)
time.sleep(1)

try:
    tty.setraw(fd)
    termios.tcflush(fd, termios.TCIFLUSH)
    os.write(out, b"\x1b[?1004h\x1b[>7u")
    deadline = time.monotonic() + 15
    while time.monotonic() < deadline:
        ready, _, _ = select.select([fd], [], [], deadline - time.monotonic())
        if ready:
            data.extend(os.read(fd, 4096))
finally:
    os.write(out, b"\x1b[<u\x1b[?1004l")
    termios.tcsetattr(fd, termios.TCSADRAIN, old)

print("\ncaptured:", repr(bytes(data)))

