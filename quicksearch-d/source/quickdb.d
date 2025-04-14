import kmeans;
import std.stdio;
import std.array;
import std.range;

class NbestMin {
  size_t size;
  size_t ndata;
  double[] dists;
  size_t[] indice;
  this(size_t n) {
    assert(n>0);
    size = n;
    ndata = 0;
    dists = uninitializedArray!(double[])(n);
    indice = uninitializedArray!(size_t[])(n);
  }
  void feed(size_t ind, double d) {
    if (ndata == 0) {
      dists[0] = d;
      indice[0] = ind;
      ndata++;
      return;
    }
    if (ndata < size) {
      for (size_t i = 0; i < ndata; i++) {
	if (d < dists[i]) {
	  for (size_t j = ndata; j > i; j--) {
	    dists[j] = dists[j-1];
	    indice[j] = indice[j-1];
	  }
	  dists[i] = d;
	  indice[i] = ind;
	  ndata++;
	  return;
	}
      }
    }
    for (size_t i = 0; i < ndata; i++) {
      if (d < dists[i]) {
	for (size_t j = ndata-1; j > i; j--) {
	  dists[j] = dists[j-1];
	  indice[j] = indice[j-1];
	}
	dists[i] = d;
	indice[i] = ind;
	return;
      }
    }
  }	
}

class QuickDB {
  double[][] data;
  size_t ncluster;
  size_t[][] cluster;
  double[][] centers;
  const size_t REDUCE_FACTOR = 100;
  //
  this(double[][] x, size_t nc = 0) {
    assert(x.length > 0);
    assert(nc >= 0);
    data = x;
    if (ncluster == 0) {
      size_t r = REDUCE_FACTOR;
      do {
	nc = x.length/r;
	r = r/2;
	if (r == 0) r = 1;
      } while (nc <= 1);
    }
    this.ncluster = nc;
    auto km = kmeans.kmeans(x,nc);
    this.cluster = uninitializedArray!(size_t[][])(nc,0);
    for (int i = 0; i < x.length; i++) {
      cluster[km.cluster[i]] ~= i;
    }
    centers = km.codebook;
  }
  static double dist2(double[] x, double[] y) {
    assert(x.length > 0);
    assert(y.length > 0);
    double d = 0;
    for (size_t i = 0; i < x.length; i++)
      d += (x[i]-y[i])*(x[i]-y[i]);
    return d;
  }
  private static NbestMin _nearest(T)(double[][] db, T ind,  double[] x, size_t nbest = 1) {
    assert(db.length > 0);
    assert(db[0].length == x.length);
    assert(isInputRange!(T));
    assert(nbest > 0);
    auto dists = new NbestMin(nbest);
    foreach (size_t i; ind) {
      auto d = dist2(db[i],x);
      dists.feed(i,d);
    }
    return dists;
  }
  size_t nearest(double[] x, size_t nbest = 1) {
    auto nearest_d = _nearest(centers,iota!size_t(ncluster),x,nbest);
    auto rdist = new NbestMin(1);
    for (size_t i = 0; i < nearest_d.ndata; i++) {
      auto r = _nearest(data,cluster[nearest_d.indice[i]],x);
      rdist.feed(r.indice[0],r.dists[0]);
    }
    return rdist.indice[0];
  }
  size_t nearest_naive(double[] x) {
    auto r = _nearest(data,iota!size_t(data.length),x);
    return r.indice[0];
  }
}

