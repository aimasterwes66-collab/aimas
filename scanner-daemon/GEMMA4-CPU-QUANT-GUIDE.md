# Gemma-4-E4B-Uncensored-HauhauCS-Aggressive — CPU-Only Deep-Dive

> **Hardware Target:** Intel i5 3.6GHz + 32GB System RAM (DDR4/DDR5)
> **Runtime:** llama.cpp via Ollama (CPU backend)
> **No GPU / No CUDA / No VRAM constraints**

---

## The CPU Reality Check

Your Intel i5 3.6GHz is a **4-core/8-thread or 6-core/12-thread** part with **AVX2** support. On CPU-only llama.cpp inference, the bottleneck is almost never compute — it's **memory bandwidth** and **cache efficiency**.

### Why This Changes Everything

| Factor | GPU (VRAM) | CPU (System RAM) |
|--------|-----------|------------------|
| **Bottleneck** | VRAM capacity | Memory bandwidth / cache misses |
| **Q8 penalty** | Runs fast (compute-bound) | Often **slower** than Q4 (bandwidth-bound) |
| **Sweet spot** | Q6_K_P for quality | **Q4_K_M / Q5_K_M** for speed/quality balance |
| **32GB ceiling** | You can load ANY quant | Context size matters more than model size |
| **IQ quants** | Good (GPU caches well) | **Slower** on CPU (lookup overhead) |

**Key insight:** On CPU, **smaller files run faster** because the CPU spends less time waiting for RAM. A Q4_K_M will often generate tokens **faster** than Q8_0 because it saturates the memory bus less.

---

## RAM Budget for 32GB System

```
Model Size    + KV Cache (per 1k ctx)  + Overhead  = Total
7.6 GB (Q8)   + ~2.5GB per 16k tokens  + ~2GB      = Fits comfortably
5.5 GB (Q5)   + ~2.5GB per 16k tokens  + ~2GB      = Sweet spot
5.1 GB (Q4)   + ~2.5GB per 16k tokens  + ~2GB      = Room to breathe
4.2 GB (Q2)   + ~2.5GB per 16k tokens  + ~2GB      = Wasted savings
```

**Rule:** With 32GB, you can run **any quant** up to ~24GB total usage. At 128k context, KV cache alone is ~20GB. That means:
- **Q8_K_P + 128k ctx = ~27GB total** → Tight but workable
- **Q5_K_P + 128k ctx = ~25GB total** → Comfortable
- **Q4_K_M + 128k ctx = ~24GB total** → Optimal

---

## Quant-by-Quant: CPU Edition

### `Q8_K_P` — 9.4 BPW, 7.6 GB
**"The Reference" — But Slower on CPU**

On GPU this is the gold standard. On your i5, it's **memory-bandwidth-starved**. Every weight fetch pulls 8 bits through the DDR bus. Your CPU cores will idle waiting for data.

**CPU Pros:**
- Maximum quality, near-lossless
- Best for short-context tasks (code review, precise reasoning)
- No quantization artifacts at all
- 32GB RAM means you can absolutely afford it

**CPU Cons:**
- **~15–20% slower tok/sec than Q5_K_M** on bandwidth-limited i5
- Higher power consumption (RAM active longer per token)
- Wastes your 32GB advantage — you're using bandwidth, not capacity
- KV cache + model + OS + other apps = you might swap at 128k context

**llama.cpp behavior:** Uses AVX2 INT8 dot products, but the speedup doesn't compensate for bandwidth cost vs Q4.

**Verdict:** Only if you need absolute quality AND keep context under 32k. Otherwise, use a smaller quant and enjoy faster generation.

---

### `Q8_0` — 8.5 BPW
**Simpler but Still Bandwidth-Hungry**

Linear INT8 without K-means grouping. On CPU, K-means grouping (the "K" variants) improves cache locality because weights are clustered. Q8_0 lacks this.

**CPU Pros:**
- Simple dequantization (fewer CPU cycles)
- Good for short prompts

**CPU Cons:**
- **Worse cache locality than Q8_K_P** on CPU
- Even slower than Q8_K_P on long context
- No reason to choose this over Q8_K_P on a 32GB system

**Verdict:** Skip. Q8_K_P is strictly better for the same size penalty.

---

### `Q6_K_P` — 7.0 BPW, 5.9 GB
**The CPU Quality Sweet Spot**

This is where quality and CPU performance start to balance. 6 bits is enough precision that quantization noise is still minimal, but the file is 22% smaller than Q8.

**CPU Pros:**
- Quality indistinguishable from Q8 for 95% of tasks
- **Faster than Q8** (~10–15% tok/sec improvement on i5)
- K-means grouping helps cache locality on CPU
- 5.9 GB leaves plenty of RAM for 64k+ context

**CPU Cons:**
- Still bandwidth-heavy compared to Q4
- Slightly slower than Q5 variants
- Not the absolute fastest option

**Verdict:** **Excellent choice** if you want near-reference quality without the Q8 bandwidth tax. Best for: coding, reasoning, long-form writing.

---

### `Q6_K` — 6.6 BPW
**Q6 Without Premium Allocation**

Removes the "preferred" bucket optimization. On CPU this means slightly worse grouping → more cache misses.

**CPU Pros:**
- Marginally faster dequant than Q6_K_P
- Still high quality

**CPU Cons:**
- Cache misses increase vs Q6_K_P
- The 0.4 BPW savings doesn't justify the grouping loss on CPU

**Verdict:** Skip. Q6_K_P is worth the extra 400MB.

---

### `Q5_K_P` — 6.1 BPW, 5.5 GB
**The CPU Default — Start Here**

On CPU, Q5_K_P hits a magical balance: small enough to keep the memory bus happy, large enough to preserve reasoning quality. The K-means "preferred" allocation is optimized for the weights that matter most.

**CPU Pros:**
- **~20–25% faster than Q8** on your i5
- Quality still excellent (~95% of fp16)
- 5.5 GB + 128k context = ~22GB total → safe on 32GB
- Cache-friendly K-means grouping
- Best speed/quality tradeoff for creative writing and chat
- Uncensored personality preserved well

**CPU Cons:**
- Slight degradation on precise math and rare tokens
- Not quite as fast as Q4 variants

**llama.cpp tip:** Use `--threads 8` (or your physical core count) and `--ctx-size 32768` for best throughput.

**Verdict:** **THE RECOMMENDED CPU QUANT.** This is your daily driver.

---

### `Q5_K_M` — 5.7 BPW, 5.4 GB
**Q5 Balanced — The Speed Demon's Choice**

Slightly more aggressive than Q5_K_P. On CPU, the smaller size translates directly to better memory bandwidth utilization.

**CPU Pros:**
- **Fastest Q5 variant** — less overhead than Q5_K_P
- Quality nearly identical to Q5_K_P for chat/creative
- 5.4 GB means even 128k context is comfortable
- Great for Ollama with multiple models loaded

**CPU Cons:**
- Cumulative errors on technical prompts
- Code block generation slightly less reliable than Q5_K_P

**Verdict:** If you want maximum speed within the Q5 family, choose this. For most users, the speed gain over Q5_K_P is marginal — stick with Q5_K_P unless you're benchmarking.

---

### `Q4_K_P` — 5.2 BPW, 5.1 GB
**The 4-bit King — CPU Champion**

Here's where CPU inference gets interesting. Q4_K_P is **often faster than Q5 and Q6** on CPU because memory bandwidth becomes the bottleneck, not compute. Your i5 can dequantize Q4 weights faster than it can fetch Q8 weights from RAM.

**CPU Pros:**
- **~30% faster than Q8** on bandwidth-limited i5
- **~10% faster than Q5_K_P** in many workloads
- 5.1 GB is tiny — tons of RAM for context
- K-means grouping (K_P) preserves cache locality
- Quality still "professional grade" for chat and writing
- Best for long-context tasks (more RAM for KV cache)

**CPU Cons:**
- ~90% of fp16 quality — degradation is now measurable
- Repetition loops more common on long generations
- Code generation: more syntax errors
- Uncensored edge dulls slightly

**Ollama behavior:** `ollama pull gemma4:q4_k_p` — this is often the most popular Ollama tag for a reason.

**Verdict:** **Best for long context or maximum tok/sec.** If you need 64k+ context regularly, Q4_K_P gives you the headroom.

---

### `Q4_K_M` — 4.8 BPW, 5.0 GB
**The CPU Performance Sweet Spot**

This is the quant that makes CPU inference feel fast. The K-means medium allocation is cache-optimized, and the 4.8 BPW means your DDR bus is barely stressed.

**CPU Pros:**
- **Fastest widely-usable quant** on CPU
- Fits in L3 cache better than higher quants (for layer shards)
- Quality perfectly adequate for chat and roleplay
- Only 5.0 GB — you could load 6 models in 32GB

**CPU Cons:**
- Personality drift noticeable on extended roleplay
- Code unreliable for complex tasks
- Factual errors increase

**Verdict:** **Best pure-performance CPU quant.** Use this if you prioritize speed over absolute quality. Great for prototyping and casual use.

---

### `IQ4_XS` — 4.3 BPW, 4.8 GB
**Imatrix — Slower on CPU, Skip It**

Imatrix (importance-aware) quantization uses lookup tables to weight error by activation frequency. On GPU this is brilliant. On CPU, the lookup overhead **kills performance**.

**CPU Pros:**
- Smarter allocation of precision
- Good size-to-quality ratio

**CPU Cons:**
- **Lookup tables cause cache thrashing on CPU**
- Often **slower than Q4_K_M** despite being smaller
- Dequantization overhead not worth it without GPU tensor cores

**Verdict:** **Skip on CPU.** Imatrix is designed for GPU inference. On your i5, the lookup overhead makes it slower than standard K-quants.

---

### `Q3_K_P` — 4.1 BPW, 4.6 GB
**The "Why Bother?" Zone**

With 32GB RAM, you have zero reason to go this low. The quality loss is severe, and the speed gain over Q4_K_M is marginal (~5%).

**CPU Pros:**
- Slightly faster than Q4
- 4.6 GB is tiny

**CPU Cons:**
- ~80% quality — obvious degradation
- Frequent loops and derailment
- Uncensored behavior becomes "mushy"
- On CPU, the 0.7 BPW savings vs Q4_K_M doesn't justify the quality hit

**Verdict:** **Don't download this.** You have 32GB. Use it.

---

### `Q3_K_M` — 3.9 BPW
**Even Worse — Skip**

**Verdict:** **Don't download this.** No benefit on your hardware.

---

### `IQ3_M` — 3.7 BPW, 4.4 GB
**Imatrix Can't Save 3 Bits**

**Verdict:** **Don't download this.**

---

### `Q2_K_P` — 3.5 BPW, 4.2 GB
**The Floor — Only for Memes**

**Verdict:** **Don't download this.** On CPU it's not even fast enough to justify the quality loss.

---

## CPU-Specific Recommendations for Your i5 + 32GB

### By Use Case

| Use Case | Recommended Quant | Why |
|----------|-------------------|-----|
| **Daily chat / creative writing** | **Q5_K_P** | Best quality at good speed |
| **Maximum tok/sec** | **Q4_K_M** | Fastest usable quant on CPU |
| **Code generation / reasoning** | **Q6_K_P** | Precision matters for syntax |
| **128k context** | **Q4_K_P** | RAM headroom for massive KV cache |
| **Multiple models in Ollama** | **Q4_K_M** | Load 5+ models simultaneously |
| **Reference / eval / testing** | **Q8_K_P** | Baseline quality comparison |
| **Roleplay / uncensored** | **Q5_K_P** | Personality preservation |

### By Context Size

| Context | Recommended Quant | RAM Estimate |
|---------|-------------------|--------------|
| 4k tokens | Q8_K_P | ~10 GB total |
| 16k tokens | Q6_K_P | ~12 GB total |
| 32k tokens | Q5_K_P | ~15 GB total |
| 64k tokens | Q4_K_P | ~20 GB total |
| 128k tokens | Q4_K_M | ~24 GB total |

### The "Load Two" Strategy

With 32GB, you can comfortably run **two models simultaneously** in Ollama:

```bash
# Fast model for chat
ollama run gemma4:q4_k_m

# High-quality model for coding
ollama run gemma4:q6_k_p
```

Ollama unloads idle models automatically, but with 32GB you can keep both resident.

---

## Ollama / llama.cpp Tuning for Your i5

### Ollama Modelfile Optimizations

```dockerfile
FROM gemma4:q5_k_p

# CPU-optimized parameters
PARAMETER num_ctx 32768
PARAMETER num_thread 8          # Match your physical cores
PARAMETER num_batch 512         # Larger batches = better CPU utilization

# Uncensored behavior
PARAMETER temperature 0.8
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """You are an unfiltered AI assistant."""
```

### llama.cpp CLI (if running raw)

```bash
./main \
  -m gemma-4-q5_k_p.gguf \
  -c 32768 \                    # Context size
  -t 8 \                        # Threads = physical cores
  -b 512 \                      # Batch size
  --memory-f32 \               # Use f32 for KV cache (better CPU precision)
  -ngl 0                        # Zero GPU layers (CPU-only)
```

### Performance Expectations (i5 3.6GHz, DDR4-3200)

| Quant | Tok/sec (prompt) | Tok/sec (generation) | Notes |
|-------|-----------------|---------------------|-------|
| Q8_K_P | ~15 tok/s | ~8 tok/s | Bandwidth starved |
| Q6_K_P | ~18 tok/s | ~10 tok/s | Good balance |
| Q5_K_P | ~22 tok/s | ~12 tok/s | **Sweet spot** |
| Q5_K_M | ~24 tok/s | ~13 tok/s | Fast Q5 |
| Q4_K_P | ~25 tok/s | ~14 tok/s | Fast + good quality |
| Q4_K_M | ~28 tok/s | ~16 tok/s | **Fastest usable** |
| Q3_K_P | ~30 tok/s | ~17 tok/s | Marginal speed gain, terrible quality |

*(Estimates vary by DDR speed, core count, and prompt complexity)*

---

## The Uncensored Factor on CPU

Aggressive uncensored fine-tunes like HauhauCS rely on precise weight configurations. On CPU, lower quants (Q3/Q2) cause:

1. **Personality collapse** — the model defaults to generic safe responses
2. **Inconsistent tone** — alternates between compliant and uncensored randomly
3. **Looping** — gets stuck in repetitive phrases

**Rule for CPU:** **Q4_K_M is the minimum** for uncensored behavior to feel coherent. Q5_K_P preserves it properly.

---

## Final Verdict for Your Setup

| Priority | Download This |
|----------|---------------|
| **Best overall** | **Q5_K_P** (5.5 GB) |
| **Maximum speed** | **Q4_K_M** (5.0 GB) |
| **Maximum quality** | **Q6_K_P** (5.9 GB) |
| **Long context** | **Q4_K_P** (5.1 GB) |
| **Reference baseline** | Q8_K_P (7.6 GB) — download once for comparison |

**Don't bother with:** Q8_0, Q6_K, Q3_K_P, Q3_K_M, IQ3_M, Q2_K_P, IQ4_XS

**Start with Q5_K_P.** If generation feels slow, drop to Q4_K_M. If quality feels off, bump to Q6_K_P. With 32GB, you have room to experiment.
