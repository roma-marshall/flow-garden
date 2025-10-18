<template>
  <div class="min-h-screen bg-gradient-to-b from-green-50 to-emerald-100 flex flex-col items-center justify-center p-8">
    <h1 class="text-4xl font-bold mb-8">🌿 Flow Garden — From Seed to Bloom</h1>

    <div v-if="!user?.addr">
      <button
          class="px-6 py-3 bg-green-600 text-white rounded-2xl shadow-md hover:bg-green-700 transition"
          @click="connectWallet"
      >
        Connect Flow Wallet
      </button>
    </div>

    <div v-else class="w-full max-w-md space-y-6">
      <div class="p-6 bg-white rounded-2xl shadow text-center">
        <p class="text-lg break-all">Connected: <b>{{ user.addr }}</b></p>
        <button
            class="mt-4 px-5 py-2 bg-red-500 text-white rounded-xl hover:bg-red-600 transition"
            @click="disconnectWallet"
        >
          Disconnect Wallet
        </button>
      </div>

      <div class="p-6 bg-white rounded-2xl shadow text-center space-y-4">
        <button
            class="w-full px-6 py-3 bg-emerald-500 text-white rounded-xl hover:bg-emerald-600 transition"
            @click="mintNFT"
        >
          🌰 Mint Seed
        </button>

        <button
            class="w-full px-6 py-3 bg-lime-500 text-white rounded-xl hover:bg-lime-600 transition"
            @click="growNFT"
        >
          🌿 Grow
        </button>

        <button
            class="w-full px-6 py-3 bg-sky-500 text-white rounded-xl hover:bg-sky-600 transition"
            @click="loadStage"
        >
          🔄 Refresh Stage
        </button>
      </div>

      <div v-if="stage" class="p-6 bg-white rounded-2xl shadow text-center">
        <p class="text-lg font-semibold">Current Stage:</p>
        <p class="text-3xl mt-2">{{ stage }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as fcl from "@onflow/fcl"

// ✅ Flow Testnet FCL config
fcl.config()
    .put("app.detail.title", "FlowGarden")
    .put("app.detail.icon", "https://flow.com/img/flow-logo.svg")
    .put("accessNode.api", "https://rest-testnet.onflow.org")
    .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn")
    .put("flow.network", "testnet")

const user = ref<any>(null)
const stage = ref<string>('')

// подписка на пользователя
fcl.currentUser.subscribe(u => (user.value = u))

// подключение кошелька
const connectWallet = async () => {
  await fcl.authenticate()
}

// ✅ новый метод — отключение кошелька
const disconnectWallet = async () => {
  await fcl.unauthenticate()
  user.value = null
  stage.value = ''
}

// mint NFT
const mintNFT = async () => {
  const txId = await fcl.mutate({
    cadence: `
      import FlowGarden from 0xeb21973261cf61d5

      transaction {
        prepare(acct: AuthAccount) {
          let nft <- FlowGarden.mint()
          acct.save(<-nft, to: /storage/MySeedNFT)
          log("✅ Minted new Seed NFT")
        }
      }
    `,
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 999
  })
  console.log("TX:", txId)
  alert("Seed NFT minted! 🌰")
  await loadStage()
}

// grow NFT
const growNFT = async () => {
  const txId = await fcl.mutate({
    cadence: `
      import FlowGarden from 0xeb21973261cf61d5

      transaction {
        prepare(acct: AuthAccount) {
          let nftRef = acct.borrow<&FlowGarden.NFT>(from: /storage/MySeedNFT)
            ?? panic("no NFT found")
          nftRef.grow()
          log("🌿 NFT grew one stage!")
        }
      }
    `,
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 999
  })
  console.log("TX:", txId)
  alert("NFT grew one stage 🌿")
  await loadStage()
}

// загрузка стадии
const loadStage = async () => {
  if (!user.value?.addr) return
  try {
    const res = await fcl.query({
      cadence: `
        import FlowGarden from 0xeb21973261cf61d5
        pub fun main(address: Address): String {
          let acct = getAccount(address)
          let ref = acct.getCapability(/storage/MySeedNFT)
            .borrow<&FlowGarden.NFT>()
          if ref == nil {
            return "🌰 No NFT yet"
          }
          let nft = ref!
          return nft.metadata["name"] ?? "Unknown"
        }
      `,
      args: (arg, t) => [arg(user.value.addr, t.Address)]
    })
    stage.value = res
  } catch (e) {
    console.warn(e)
  }
}

// подгрузка при входе
onMounted(() => {
  if (user.value?.addr) loadStage()
})
</script>

<style scoped>
body {
  font-family: system-ui, sans-serif;
}
</style>
