public enum VideoInventoryFormatEnum: Codable {
    case InStream
    case OutStream
}

public enum SkippableEnum: Codable {
    case UNKNOWN
    case ALLOW
    case NOT_ALLOW
    case REQUIRE
}

public enum VideoProtocolEnum: Codable {
    case Vast1
    case Vast2
    case Vast3
    case Vast1Wrapper
    case Vast2Wrapper
    case Vast3Wrapper
    case Vast4
    case Vast4Wrapper
    case Daast1
    case Daast1Wrapper
    case Vast41
    case Vast41Wrapper
}

public enum ApiFrameworkEnum: Codable {
    case Vpaid1
    case Vpaid2
    case Mraid3
    case Orma
    case Mraid2
    case Omidi
}
