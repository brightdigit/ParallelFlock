# ParallelReduceOperation
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">class</span> <span class="kt">ParallelReduceOperation</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span><span class="p">:</span> <span class="kt"><a href="../Protocols/ParallelOperation.md">ParallelOperation</a></span></code></pre>

<p>Undocumented</p>

### source
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">]</span></code></pre>

<p>Undocumented</p>

### itemClosure
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">itemClosure</span><span class="p">:</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A17ReduceItemClosurea">ParallelReduceItemClosure</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span></code></pre>

<p>Undocumented</p>

### completion
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">completion</span><span class="p">:</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A19OperationCompletiona">ParallelOperationCompletion</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span></code></pre>

<p>Undocumented</p>

### itemQueue
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">itemQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span></code></pre>

<p>Undocumented</p>

### mainQueue
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">mainQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span></code></pre>

<p>Undocumented</p>

### arrayQueue
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">arrayQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span></code></pre>

<p>Undocumented</p>

### status
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">status</span><span class="p">:</span> <span class="kt"><a href="../Enums/ParallelOperationStatus.md">ParallelOperationStatus</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span> <span class="o">=</span> <span class="o">.</span><span class="n">initialized</span></code></pre>

<p>Undocumented</p>

### temporaryResult
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">temporaryResult</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">]</span></code></pre>

<p>Undocumented</p>

### iterationCount
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">private(set)</span> <span class="k">var</span> <span class="nv">iterationCount</span><span class="p">:</span> <span class="kt">Int</span> <span class="o">=</span> <span class="mi">0</span></code></pre>

<p>Undocumented</p>

### maxIterations
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">var</span> <span class="nv">maxIterations</span><span class="p">:</span> <span class="kt">Int</span></code></pre>

<p>Undocumented</p>

### init(source:itemClosure:completion:queue:itemQueue:arrayQueue:)
<pre class="highlight swift"><code><span class="kd">public</span> <span class="nf">init</span><span class="p">(</span>
  <span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">],</span>
  <span class="nv">itemClosure</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A17ReduceItemClosurea">ParallelReduceItemClosure</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span><span class="p">,</span>
  <span class="nv">completion</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="kt"><a href="../Typealiases.md#/s:13ParallelFlock0A19OperationCompletiona">ParallelOperationCompletion</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span><span class="p">,</span>
  <span class="nv">queue</span><span class="p">:</span> <span class="kt">DispatchQueue</span><span class="p">?</span> <span class="o">=</span> <span class="kc">nil</span><span class="p">,</span>
  <span class="n"><a href="../Classes/ParallelReduceOperation.md#/s:13ParallelFlock0A15ReduceOperationC9itemQueueSo08DispatchF0Cvp">itemQueue</a></span> <span class="nv">_</span><span class="p">:</span> <span class="kt">DispatchQueue</span><span class="p">?</span> <span class="o">=</span> <span class="kc">nil</span><span class="p">,</span>
  <span class="nv">arrayQueue</span><span class="p">:</span> <span class="kt">DispatchQueue</span><span class="p">?</span> <span class="o">=</span> <span class="kc">nil</span><span class="p">)</span></code></pre>

<p>Undocumented</p>

### begin()
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">func</span> <span class="nf">begin</span><span class="p">()</span></code></pre>

<p>Undocumented</p>

### zipArray(_:)
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">func</span> <span class="nf">zipArray</span><span class="p">(</span><span class="n">_</span> <span class="nv">array</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">])</span> <span class="o">-&gt;</span> <span class="p">(</span><span class="kt">Zip2Sequence</span><span class="o">&lt;</span><span class="kt">ArraySlice</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span><span class="p">,</span> <span class="kt">ArraySlice</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;&gt;</span><span class="p">,</span> <span class="kt">T</span><span class="p">?)</span></code></pre>

<p>Undocumented</p>

### iterate()
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">func</span> <span class="nf">iterate</span><span class="p">()</span></code></pre>

<p>Undocumented</p>

