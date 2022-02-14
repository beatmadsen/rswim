module RSwim
  module Encryption
    class << self
      def encrypt(message)
        message = message.dup.force_encoding('UTF-8')
        salt = cipher.random_iv        
        cipher_text = cipher.update(message) + cipher.final
        [cipher_text, salt]
      rescue StandardError => e
        raise Error, "Failed to encrypt: #{e.message}"
      end

      def decrypt(cipher_text, salt)
        decipher.iv = salt
        message = decipher.update(cipher_text) + decipher.final
        message.force_encoding('UTF-8')
      rescue StandardError => e
        raise Error, "Failed to decrypt: #{e.message}"        
      end

      private

      def cipher
        @_cipher ||= begin
          cipher = OpenSSL::Cipher::AES256.new :CBC
          cipher.encrypt
          cipher.key = Digest::SHA256.digest(RSwim.shared_secret)
          cipher
        end
      end

      def decipher
        @_decipher ||= begin
          cipher = OpenSSL::Cipher::AES256.new :CBC
          cipher.decrypt
          cipher.key = Digest::SHA256.digest(RSwim.shared_secret)
          cipher
        end
      end
    end

  end
end