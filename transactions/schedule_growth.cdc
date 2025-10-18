import FlowTransactionScheduler from 0x8c5303eaa26202d6
import GrowActionContract from 0xeb21973261cf61d5
import FlowGarden from 0xeb21973261cf61d5

transaction {
    prepare(acct: AuthAccount) {
        let nftRef = acct.borrow<&FlowGarden.NFT>(from: /storage/MySeedNFT)
            ?? panic("no NFT in storage")

        // 🔧 исправлено: используем intersection type &{...}
        let schedulerRef = acct
            .getCapability<&{FlowTransactionScheduler.ManagerPublic}>(
                FlowTransactionScheduler.PublicPath
            )
            .borrow()
            ?? panic("no scheduler capability")

        let handler <- GrowActionContract.createHandler(gardenRef: nftRef)

        let now: UFix64 = getCurrentBlock().timestamp
        let interval: UFix64 = 86400.0  // 24 часа

        let id = schedulerRef.schedule(
            handler: <- handler,
            executeAt: now + interval,
            repeatInterval: interval,
            maxExecutions: 3
        )

        log("🌿 Scheduled growth ID: ".concat(id.toString()))
    }
}
