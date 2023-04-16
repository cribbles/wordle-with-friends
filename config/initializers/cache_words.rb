secret_word = ENV["SECRET_WORD"] if Rails.env.development?
if secret_word.present? && secret_word.size != 5
  puts "Can't boot: SECRET_WORD needs to be five characters long"
  exit(1)
end

valid_words = File.readlines('./app/assets/cache/words.txt', chomp: true)
words = if secret_word.present?
  [secret_word]
else
  valid_words
end
guesses = File.readlines('./app/assets/cache/guesses.txt', chomp: true)
Rails.cache.write(:words, words)
Rails.cache.write(:guesses, valid_words + guesses)
