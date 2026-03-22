import CustomDump
import Testing

import PersistenceKit

struct BreedTests {
    @Test
    func parseLifeSpanParsesNumericRange() {
        let lifeSpan = Breed.parseLifeSpan("12 - 15")

        expectNoDifference(
            [lifeSpan.lower, lifeSpan.upper],
            [12, 15]
        )
    }

    @Test
    func parseLifeSpanReturnsNilBoundsForUnexpectedFormat() {
        let lifeSpan = Breed.parseLifeSpan("up to 15 years")

        expectNoDifference(
            [lifeSpan.lower, lifeSpan.upper],
            [nil, nil]
        )
    }
}
