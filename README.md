# Cappt
Cappt, the cat app.
- Shows breeds and breeds details
- Supports search
- Favoriting of breeds
- Average age of favorite breeds (using upper age, let's be optimistic)


## Project Overview
- `Cappt`: app composition and launch flow
- `BreedsFeature`: breeds list, favorites, search, details
- `PersistenceKit`: Core Data storage and cache access
- `NetworkKit`: HTTP client and image caching
- `AppUI`: shared UI building blocks and theme

## Development Notes
- Even though I'm more familiar with MVVM, I chose TCA as a challenge for myself.
- I kept the project modular so networking, persistence, UI components, and features can evolve independently without coupling everything.
- (But) I tried not to go overboard with modularity for this small project. Would consider splitting functionality into more modules as the project grows. For example maybe List and Details screens could go into their own modules if they grow a lot. For example ImageCache should go into a different module.
- Started by having the UI up and running with mock data, then started adding other functionality like API support, caching, search, etc.
- Tried to keep a balance with tests timewise, there's room for more tests.

## Future Work / Improvements
- Downscale image on download to reduce disk space and faster loading
- Improve network code: throttling to not request too many images simultaneously and handling of backpressure to relief the server
- Pull down to refresh list
- Improve the UI/UX
- Increase test coverage
- Improve accessibility
- Certificate pinning
- Device attestation
