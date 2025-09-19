import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  define: {
    global: 'globalThis',
  },
  resolve: {
    alias: {
      buffer: 'buffer',
    },
  },
  optimizeDeps: {
    include: [
      'buffer',
      'bn.js',
      'ethers/lib/utils',
      'web3modal'
    ],
    exclude: []
  },
  build: {
    commonjsOptions: {
      transformMixedEsModules: true
    }
  }
})
