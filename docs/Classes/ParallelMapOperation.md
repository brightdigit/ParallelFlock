# ParallelMapOperation
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">class</span> <span class="kt">ParallelMapOperation</span><span class="o">&lt;</span><span class="kt">T</span><span class="p">,</span> <span class="kt">U</span><span class="o">&gt;</span><span class="p">:</span> <span class="kt"><a href="../Protocols/ParallelOperation.md">ParallelOperation</a></span></code></pre>

<p>The operation for a parallel map.</p>

### source
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">]</span></code></pre>

<p>The source array.</p>

### transform
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">transform</span><span class="p">:</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A12MapTransforma">ParallelMapTransform</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="p">,</span> <span class="kt">U</span><span class="o">&gt;</span></code></pre>

<p>The item mapping closure.</p>

### completion
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">completion</span><span class="p">:</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A13MapCompletiona">ParallelMapCompletion</a></span><span class="o">&lt;</span><span class="kt">U</span><span class="o">&gt;</span></code></pre>

<p>The completion closure.</p>

### itemQueue
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">itemQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span></code></pre>

<p>The DispatchQueue for each item map.</p>

### mainQueue
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">mainQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span></code></pre>

<p>The DispatchQueue for the main operation.</p>

### status
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">status</span> <span class="o">=</span> <span class="kt"><a href="../Enums/ParallelOperationStatus.md">ParallelOperationStatus</a></span><span class="o">&lt;</span><span class="p">[</span><span class="kt">U</span><span class="p">]</span><span class="o">&gt;.</span><span class="n">initialized</span></code></pre>

<p>Undocumented</p>

### temporaryPointer
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">temporaryPointer</span><span class="p">:</span> <span class="kt">UnsafeMutablePointer</span><span class="o">&lt;</span><span class="kt">U</span><span class="o">&gt;!</span></code></pre>

<p>Undocumented</p>

### memoryCapacity
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">var</span> <span class="nv">memoryCapacity</span><span class="p">:</span> <span class="kt">Int</span></code></pre>

<p>Undocumented</p>

### init(source:transform:completion:queue:itemQueue:)
<pre class="highlight swift"><code><span class="kd">public</span> <span class="nf">init</span><span class="p">(</span>
  <span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">],</span>
  <span class="nv">transform</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A12MapTransforma">ParallelMapTransform</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="p">,</span> <span class="kt">U</span><span class="o">&gt;</span><span class="p">,</span>
  <span class="nv">completion</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A13MapCompletiona">ParallelMapCompletion</a></span><span class="o">&lt;</span><span class="kt">U</span><span class="o">&gt;</span><span class="p">,</span>
  <span class="nv">queue</span><span class="p">:</span> <span class="kt">DispatchQueue</span><span class="p">?</span> <span class="o">=</span> <span class="kc">nil</span><span class="p">,</span>
  <span class="n"><a href="../Classes/ParallelMapOperation.md#/s:13ParallelFlock0A12MapOperationC9itemQueueSo08DispatchF0Cvp">itemQueue</a></span> <span class="nv">_</span><span class="p">:</span> <span class="kt">DispatchQueue</span><span class="p">?</span> <span class="o">=</span> <span class="kc">nil</span><span class="p">)</span></code></pre>

<p>Creates <em>ParallelMapOperation</em>.</p>

### begin()
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">func</span> <span class="nf">begin</span><span class="p">()</span></code></pre>

<p>Begins the operation.</p>

