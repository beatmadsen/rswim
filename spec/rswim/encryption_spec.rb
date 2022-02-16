RSpec.describe RSwim::Encryption do
  before do
    RSwim.encrypted = true
    RSwim.shared_secret = 'asimov'
  end

  it 'can encrypt a message' do
    cipher_text, salt = RSwim::Encryption.encrypt('cowbell')
    expect(cipher_text).to_not eq('cowbell')
  end

  it 'can decrypt a message' do
    cipher_text = ";Do\x15\x98(\x10\x85T)\xEA\xAC\xC4\xF5Y\x8B"    
    salt = "\xB0|F0\xE3\xB5\x0E~uIL\x90\x91+\xA3\x8D"

    message = RSwim::Encryption.decrypt(cipher_text, salt)
    expect(message).to_not eq(cipher_text)
  end

  it 'decrypts to the original including non-standard letters' do
    original = "kaffe og kage igå 42 ɑΩϕβΣπ"
    cipher_text, salt = RSwim::Encryption.encrypt(original)

    message = RSwim::Encryption.decrypt(cipher_text, salt)
    expect(message).to eq(original)
  end
end
