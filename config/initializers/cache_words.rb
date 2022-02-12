words = File.readlines('./app/assets/cache/words.txt', chomp: true)
guesses = File.readlines('./app/assets/cache/guesses.txt', chomp: true)
Rails.cache.write(:words, words)
Rails.cache.write(:guesses, words + guesses)