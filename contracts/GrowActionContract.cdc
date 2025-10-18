// адрес контракта планировщика (testnet)
import FlowTransactionScheduler from 0x8c5303eaa26202d6
import FlowGarden from 0xeb21973261cf61d5

access(all) contract GrowActionContract {

    // ресурс-обработчик, который будет вызываться планировщиком
    access(all) resource GrowHandler: FlowTransactionScheduler.TransactionHandler {
        access(all) let gardenRef: &FlowGarden.NFT

        init(gardenRef: &FlowGarden.NFT) {
            self.gardenRef = gardenRef
        }

        // метод, который вызывается планировщиком
        access(FlowTransactionScheduler.Execute)
        fun executeTransaction(id: UInt64, data: AnyStruct?) {
            self.gardenRef.grow()
            log("🌿 NFT grew one stage via scheduler (id=".concat(id.toString()).concat(")"))
        }
    }

    // фабрика для создания обработчика
    access(all) fun createHandler(gardenRef: &FlowGarden.NFT): @GrowHandler {
        return <- create GrowHandler(gardenRef: gardenRef)
    }
}
