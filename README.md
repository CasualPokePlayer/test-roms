# rtc-invalid-banks-test

This test aims to identify how "banks" past normal RAM banks but not valid RTC registers behave.

Disclaimer: This test is only meant for the MBC3's RTC. It is not for other mappers' RTC implementations.

# Result

![GBI00077](https://user-images.githubusercontent.com/50538166/114638896-71ddaf00-9c81-11eb-8550-eb087e08901f.PNG)

# Conclusion

The RAMB register for MBC3+RTC is a 4 bit register. The upper 4 bits do not affect the bank selected.

When RTC is present, all 4 bits must be used, thus all are connected.

There is a range of 16 combinations that can be mapped. However, only up to 4 RAM banks can be mapped to the MBC3, and there are only 5 RTC registers present, leaving only 9 possible valid combinations.

This leaves "banks" 04-07 and 0D-0F never mapping to anything.

The test seems to show that these invalid "banks" appear to produce open bus behavior.

Disclaimer: This test was originally ran within ROM. This produce noticable open bus behavior (i.e. last opcode executed read) with these invalid "banks". The test now does reads from HRAM to consistency read $FF.
