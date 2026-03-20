public struct Breed: Equatable, Identifiable, Sendable {
    public let description: String
    public let id: String
    public let imageURL: String
    public let name: String
    public let origin: String
    public let temperament: String
    public var isFavorite: Bool
    
    public init(
        description: String,
        id: String,
        imageURL: String,
        isFavorite: Bool,
        name: String,
        origin: String,
        temperament: String
    ) {
        self.description = description
        self.id = id
        self.imageURL = imageURL
        self.isFavorite = isFavorite
        self.name = name
        self.origin = origin
        self.temperament = temperament
    }
}

public extension Breed {
    static let mock: [Self] = [
        Self(
            description: "Abyssinians are athletic, curious cats that stay busy and tend to bond closely with the people around them.",
            id: "abyssinian",
            imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
            isFavorite: false,
            name: "Abyssinian",
            origin: "Ethiopia",
            temperament: "Active, Energetic, Independent, Intelligent, Gentle"
        ),
        Self(
            description: "Bengals are confident, playful cats with a strong hunting instinct and a high need for stimulation.",
            id: "bengal",
            imageURL: "https://cdn2.thecatapi.com/images/O3btzLlsO.png",
            isFavorite: true,
            name: "Bengal",
            origin: "United States",
            temperament: "Alert, Agile, Energetic, Demanding, Intelligent",
        ),
        Self(
            description: "British Shorthairs are calm, sturdy companions known for their easygoing nature and plush coat.",
            id: "british-shorthair",
            imageURL: "https://cdn2.thecatapi.com/images/czK4XQw8X.jpg",
            isFavorite: false,
            name: "British Shorthair",
            origin: "United Kingdom",
            temperament: "Affectionate, Easy Going, Gentle, Loyal, Calm",
        ),
        Self(
            description: "Devon Rex cats are mischievous, social, and always looking for warmth, height, and attention.",
            id: "devon-rex",
            imageURL: "https://cdn2.thecatapi.com/images/4RzEwvyzz.jpg",
            isFavorite: false,
            name: "Devon Rex",
            origin: "United Kingdom",
            temperament: "Highly interactive, Mischievous, Loyal, Social, Playful",
        ),
        Self(
            description: "Maine Coons are large, friendly cats with a gentle temperament and a strong tolerance for family life.",
            id: "maine-coon",
            imageURL: "https://cdn2.thecatapi.com/images/OOI-aI_vD.jpg",
            isFavorite: true,
            name: "Maine Coon",
            origin: "United States",
            temperament: "Adaptable, Intelligent, Loving, Gentle, Independent",
        ),
        Self(
            description: "Norwegian Forest cats are hardy climbers with a balanced temperament and a composed, affectionate side.",
            id: "norwegian-forest",
            imageURL: "https://cdn2.thecatapi.com/images/0A2uS6oJD.jpg",
            isFavorite: false,
            name: "Norwegian Forest",
            origin: "Norway",
            temperament: "Sweet, Active, Intelligent, Social, Playful",
        ),
        Self(
            description: "Persians are quiet, affectionate cats that prefer predictable environments and relaxed companionship.",
            id: "persian",
            imageURL: "https://cdn2.thecatapi.com/images/-Zfz5z2jK.jpg",
            isFavorite: true,
            name: "Persian",
            origin: "Iran",
            temperament: "Affectionate, Loyal, Sedate, Quiet, Sweet",
        ),
        Self(
            description: "Ragdolls are relaxed, people-oriented cats that enjoy following their humans and settling into routines.",
            id: "ragdoll",
            imageURL: "https://cdn2.thecatapi.com/images/oTet8p6yC.jpg",
            isFavorite: false,
            name: "Ragdoll",
            origin: "United States",
            temperament: "Affectionate, Friendly, Gentle, Quiet, Easy Going",
        ),
        Self(
            description: "Russian Blues are elegant, observant cats that are reserved at first and deeply loyal once comfortable.",
            id: "russian-blue",
            imageURL: "https://cdn2.thecatapi.com/images/hcEfeYf6b.jpg",
            isFavorite: true,
            name: "Russian Blue",
            origin: "Russia",
            temperament: "Quiet, Loyal, Intelligent, Gentle, Reserved",
        ),
        Self(
            description: "Scottish Folds are sweet-natured cats with a soft voice and a strong preference for nearby company.",
            id: "scottish-fold",
            imageURL: "https://cdn2.thecatapi.com/images/o9t0LDcsa.jpg",
            isFavorite: false,
            name: "Scottish Fold",
            origin: "Scotland",
            temperament: "Affectionate, Intelligent, Loyal, Playful, Social",
        ),
        Self(
            description: "Siamese cats are vocal, clever, and highly social animals that expect engagement throughout the day.",
            id: "siamese",
            imageURL: "https://cdn2.thecatapi.com/images/ai6Jps4sx.jpg",
            isFavorite: true,
            name: "Siamese",
            origin: "Thailand",
            temperament: "Active, Agile, Clever, Sociable, Loving",
        ),
        Self(
            description: "Sphynx cats are extroverted, energetic companions that trade fur for warmth-seeking behavior and attention.",
            id: "sphynx",
            imageURL: "https://cdn2.thecatapi.com/images/BDb8ZXb1v.jpg",
            isFavorite: false,
            name: "Sphynx",
            origin: "Canada",
            temperament: "Loyal, Inquisitive, Friendly, Energetic, Affectionate",
        ),
    ]
}
