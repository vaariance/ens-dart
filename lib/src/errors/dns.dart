part of 'errors.dart';

class DnsResponseStatusError extends BaseError {
  final String responseStatus;

  @override
  final String name = 'DnsResponseStatusError';

  DnsResponseStatusError({required this.responseStatus})
      : super(shortMessage: 'DNS query failed with status: $responseStatus');
}

class DnsDnssecVerificationFailedError extends BaseError {
  final String? record;

  @override
  final String name = 'DnsDnssecVerificationFailedError';

  DnsDnssecVerificationFailedError({this.record})
      : super(shortMessage: 'DNSSEC verification failed');
}

class DnsNoTxtRecordError extends BaseError {
  @override
  final String name = 'DnsNoTxtRecordError';

  DnsNoTxtRecordError() : super(shortMessage: 'No TXT record found');
}

class DnsInvalidTxtRecordError extends BaseError {
  final String record;

  @override
  final String name = 'DnsInvalidTxtRecordError';

  DnsInvalidTxtRecordError({required this.record})
      : super(shortMessage: 'Invalid TXT record: $record');
}

class DnsInvalidAddressChecksumError extends BaseError {
  final String address;

  @override
  final String name = 'DnsInvalidAddressChecksumError';

  DnsInvalidAddressChecksumError({required this.address})
      : super(shortMessage: 'Invalid address checksum: $address');
}

class DnsNewerRecordTypeAvailableError extends BaseError {
  final String typeCovered;
  final String signatureName;
  final int onchainInception;
  final int dnsInception;

  @override
  final String name = 'DnsNewerRecordTypeAvailableError';

  DnsNewerRecordTypeAvailableError({
    required this.typeCovered,
    required this.signatureName,
    required this.onchainInception,
    required this.dnsInception,
  }) : super(
          shortMessage:
              'DNSSEC Oracle has a newer version of the $typeCovered RRSET on $signatureName',
          parameters: BaseErrorParameters(
            metaMessages: [
              '- Onchain inception: $onchainInception',
              '- DNS inception: $dnsInception',
            ],
          ),
        );
}
