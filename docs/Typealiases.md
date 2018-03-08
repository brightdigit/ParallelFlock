# Type Aliases
<p>The following type aliases are available globally.</p>

### ParallelMapTransform
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">typealias</span> <span class="kt">ParallelMapTransform</span><span class="o">&lt;</span><span class="kt">T</span><span class="p">,</span> <span class="kt">U</span><span class="o">&gt;</span> <span class="o">=</span> <span class="p">(</span><span class="kt">T</span><span class="p">,</span> <span class="kd">@escaping</span> <span class="p">(</span><span class="kt">U</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span></code></pre>

<p>Undocumented</p>

### ParallelOperationCompletion
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">typealias</span> <span class="kt">ParallelOperationCompletion</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span> <span class="o">=</span> <span class="p">(</span><span class="kt">T</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span></code></pre>

<p>Undocumented</p>

### ParallelReduceItemClosure
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">typealias</span> <span class="kt">ParallelReduceItemClosure</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span> <span class="o">=</span> <span class="p">(</span><span class="kt">T</span><span class="p">,</span> <span class="kt">T</span><span class="p">,</span> <span class="kd">@escaping</span> <span class="p">(</span><span class="kt">T</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span></code></pre>

<p>Undocumented</p>

### ParallelMapCompletion
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">typealias</span> <span class="kt">ParallelMapCompletion</span><span class="o">&lt;</span><span class="kt">U</span><span class="o">&gt;</span> <span class="o">=</span> <span class="kt"><a href="Typealiases.md#/s:13ParallelFlock0A19OperationCompletiona">ParallelOperationCompletion</a></span><span class="o">&lt;</span><span class="p">[</span><span class="kt">U</span><span class="p">]</span><span class="o">&gt;</span></code></pre>

<p>Undocumented</p>

