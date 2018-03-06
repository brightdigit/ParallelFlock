# Parallel
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">class</span> <span class="kt">Parallel</span><span class="o">&lt;</span><span class="kt">T</span><span class="o">&gt;</span></code></pre>

<p>Undocumented</p>

### source
<pre class="highlight swift"><code><span class="kd">public</span> <span class="k">let</span> <span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">]</span></code></pre>

<p>Undocumented</p>

### init(source:)
<pre class="highlight swift"><code><span class="kd">public</span> <span class="nf">init</span><span class="p">(</span><span class="nv">source</span><span class="p">:</span> <span class="p">[</span><span class="kt">T</span><span class="p">])</span></code></pre>

<p>Undocumented</p>

### map(_:completion:)
<pre class="highlight swift"><code><span class="kd">public</span> <span class="kd">func</span> <span class="n">map</span><span class="o">&lt;</span><span class="kt">U</span><span class="o">&gt;</span><span class="p">(</span>
  <span class="n">_</span> <span class="nv">each</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="p">(</span><span class="kt">T</span><span class="p">,</span> <span class="kd">@escaping</span> <span class="p">(</span><span class="kt">U</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt">Void</span><span class="p">,</span>
  <span class="nv">completion</span><span class="p">:</span> <span class="kd">@escaping</span> <span class="p">([</span><span class="kt">U</span><span class="p">])</span> <span class="o">-&gt;</span> <span class="kt">Void</span><span class="p">)</span> <span class="o">-&gt;</span> <span class="kt"><a href="../Classes/ParallelMapOperation.md">ParallelMapOperation</a></span><span class="o">&lt;</span><span class="kt">T</span><span class="p">,</span> <span class="kt">U</span><span class="o">&gt;</span></code></pre>

<p>Undocumented</p>

