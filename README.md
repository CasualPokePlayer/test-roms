# Open Bus Single Speed Test

This test aims to study the affects of open bus behavior with disabled/no SRAM in single speed mode (i.e. just normal DMG speed).

# Result

![GBI00078](https://user-images.githubusercontent.com/50538166/115127205-8b387100-9f89-11eb-886d-fa81718e22b5.PNG)

# Conclusion

Open bus behavior seems to just take the value of the last opcode read. However, it appears this value will quickly degrade over time, pulling up to 0xFF, as seen with pop reads.
