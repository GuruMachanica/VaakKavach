class RiskEngineRule {
  final String pattern;
  final String alertTag;
  final String userAlert;

  const RiskEngineRule(this.pattern, this.alertTag, this.userAlert);
}

const List<RiskEngineRule> kRiskEngineRules = [
  RiskEngineRule(
    r'\botp\b|verification\s*code|ओटीपी|ஓடிபி|ఓటీపీ|ಒಟಿಪಿ',
    'otp_threat',
    '🚨 ALERT: Caller is requesting an OTP or verification code. NEVER share it!',
  ),
  RiskEngineRule(
    r'\bpin\b|upi\s*pin|पिन',
    'pin_threat',
    '🚨 ALERT: Caller asked for your PIN. Entering a PIN will DEDUCT money!',
  ),
  RiskEngineRule(
    r'\bcvv\b|card\s*number|credit\s*card|debit\s*card',
    'card_details',
    '⚠️ WARNING: Card numbers or CVV requested. Never disclose card details!',
  ),
  RiskEngineRule(
    r'bank\s*account|ifsc|खाता|बँक\s*खाते',
    'bank_details',
    '⚠️ WARNING: Bank account details requested. Verify caller identity.',
  ),
  RiskEngineRule(
    r'digital\s*arrest|cbi|police|customs|narcotics|crime\s*branch|supreme\s*court|पोलीस|கைது|डिजिटल\s*अरेस्ट',
    'digital_arrest',
    '🚨 CRITICAL: Digital Arrest / Extortion scam detected! Law enforcement never holds phone or Skype trials.',
  ),
  RiskEngineRule(
    r'anydesk|teamviewer|quicksupport|rustdesk|screen\s*share|apk\s*file',
    'remote_access_trap',
    '🚨 CRITICAL ALERT: Caller requesting remote access / screen-sharing app! They are attempting to take over your phone.',
  ),
  RiskEngineRule(
    r'parcel\s*seized|illegal\s*package|drugs\s*found|customs\s*clearance|fedex|dhl',
    'courier_scam',
    '⚠️ WARNING: Fake courier/customs narcotics extortion trap. Legitimate parcel services do not threaten arrest.',
  ),
  RiskEngineRule(
    r'do\s*not\s*disconnect|stay\s*on\s*call|lock\s*your\s*room|isolate|do\s*not\s*tell\s*anyone|secret',
    'isolation_coercion',
    '🚨 DANGER: Psychological isolation tactic detected. Scammers isolate victims to prevent family intervention.',
  ),
  RiskEngineRule(
    r'kyc\s*update|block\s*your\s*account|freeze\s*account|खाता\s*ब्लॉक|बंद\s*हो\s*जाएगा',
    'kyc_urgency',
    '⚠️ WARNING: KYC freeze threat detected. Official banks do not freeze accounts over call.',
  ),
  RiskEngineRule(
    r'transfer\s*money|send\s*money|पैसे\s*भेजो|टাকা\s*পাঠাও|பணம்\s*அனுப்பு|డబ్బులు\s*పంపండి|ಹಣ\s*ಕಳುಹಿಸಿ|पैसे\s*पाठवा',
    'transfer_request',
    '🚨 DANGER: Urgent money transfer demand detected.',
  ),
  RiskEngineRule(
    r'lottery|reward\s*claim|jackpot|लॉटरी',
    'lottery_scam',
    '⚠️ WARNING: Lottery claim or prize scam detected.',
  ),
];
