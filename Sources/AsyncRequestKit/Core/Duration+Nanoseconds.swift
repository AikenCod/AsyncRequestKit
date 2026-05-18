extension Duration {
    var asyncRequestKitNanoseconds: UInt64 {
        let components = components
        let seconds = max(components.seconds, 0)
        let secondsNanoseconds = UInt64(seconds).multipliedReportingOverflow(by: 1_000_000_000)
        let attosecondNanoseconds = max(components.attoseconds, 0) / 1_000_000_000

        if secondsNanoseconds.overflow {
            return UInt64.max
        }

        let total = secondsNanoseconds.partialValue.addingReportingOverflow(UInt64(attosecondNanoseconds))
        return total.overflow ? UInt64.max : total.partialValue
    }

    static func asyncRequestKitNanoseconds(_ nanoseconds: UInt64) -> Duration {
        if nanoseconds > UInt64(Int64.max) {
            return .nanoseconds(Int64.max)
        }
        return .nanoseconds(Int64(nanoseconds))
    }
}
