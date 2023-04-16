# Wordle With Friends

This is a multiplayer Wordle clone written in [Rails 7](https://rubyonrails.org/), using [Hotwire](https://hotwired.dev/) for interactivity and live updates.

## Live

https://friendle.fly.dev/

## Local deployment

### Running the application

```sh
# Enable cache in development mode. You should only have to do this once
rails dev:cache

# Spin the app up locally
rails server

# Optionally, you can make each room always resolve to the same five-letter
# word of your choice -- this is a little nicer for debugging
SECRET_WORD=xxxxx rails server
```

## Tests

```sh
rails test
```

## How it works

You know how to [Wordle](https://www.nytimes.com/games/wordle/index.html).

You can either play solo or with a partner. Entering the app from the root URL drops you into a new room automatically; you can start playing with someone else by sharing the URL with that person, which invites them to join. After each game you can choose to start over with a new word or share your results (using the same formatting as OG Wordle).

### Technical details

The backend is a fairly standard Rails app with the Room -> Player -> Guess relationships you would expect.

The frontend is pure Hotwire: basically a mix of ERB templates and Stimulus controllers (see `app/javascript/controllers`), with UI updates driven by websockets via Turbo streams. If you're not familiar with Hotwire, you might also liken this to Phoenix's [LiveView](https://github.com/phoenixframework/phoenix_live_view) paradigm.

Probably the most interesting "under the hood" implementation detail is user auth. Each player is allocated an ID and password on creation. The ID is "public", i.e. it's baked in to the DOM state (it has to be this way for UI updates, so Turbo knows which frame to append guesses to). The password is only exposed to the user, and only via session data. This enables players to see their own guesses, but not have their partner's guesses revealed (aside from the guess evaluations - i.e., the gray/green/yellow squares) until the game is over.

## License

MIT
