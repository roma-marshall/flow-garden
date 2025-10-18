access(all) contract FlowGarden {

    // ✅ современный enum-синтаксис Cadence 1.0
    access(all) enum Stage: UInt8 {
        access(all) case Seed
        access(all) case Sprout
        access(all) case Bloom
    }

    access(all) resource NFT {
        access(all) var id: UInt64
        access(all) var stage: Stage
        access(all) var metadata: {String: String}

        init(id: UInt64, stage: Stage, metadata: {String: String}) {
            self.id = id
            self.stage = stage
            self.metadata = metadata
        }

        access(all) fun grow() {
            if self.stage == Stage.Seed {
                self.stage = Stage.Sprout
                self.metadata["name"] = "Sprout 🌱"
            } else if self.stage == Stage.Sprout {
                self.stage = Stage.Bloom
                self.metadata["name"] = "Bloom 🌸"
            }
        }
    }

    access(contract) var totalMinted: UInt64

    access(all) fun mint(): @NFT {
        self.totalMinted = self.totalMinted + 1
        return <- create NFT(
            id: self.totalMinted,
            stage: Stage.Seed,
            metadata: {"name": "Seed 🌰"}
        )
    }

    init() {
        self.totalMinted = 0
    }
}
