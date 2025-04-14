import std.stdio;
import std.array;
import std.math;
import std.random;
import std.range;

double distance(double[] x, double[] y)
{
    assert(x.length == y.length);
    double d = 0.0;
    for (size_t i = 0; i < x.length; i++) {
      d += (x[i]-y[i])*(x[i]-y[i]);
    }
    return d;
}

size_t nearest(double[][] codebook, double[] x)
{
   double min = distance(codebook[0],x);
   size_t pos = 0;
   for (size_t i = 1; i < codebook.length; i++) {
       double d = distance(codebook[i],x);
       if (d < min) {
           min = d;
	   pos = i;
       }
   }
   return pos;
}

void calc_centroid(double[][] codebook, double[][] x, size_t[] cluster)
{
   assert(x.length == cluster.length);
   for (size_t i = 0; i < codebook.length; i++) {
       for (size_t j = 0; j < codebook[0].length; j++) {
           codebook[i][j] = 0.0;
       }
   }
   auto count = new int[codebook.length];
   for (size_t i = 0; i < x.length; i++) {
       auto c = cluster[i];
       count[c]++;
       for (size_t j = 0; j < x[0].length; j++) {
           codebook[c][j] += x[i][j];
       }
   }
   for (size_t c = 0; c < codebook.length; c++) {
       for (size_t j = 0; j < codebook[0].length; j++)
           codebook[c][j] /= count[c];
   }
}

struct Kmeans {
  double[][] codebook;
  size_t[] cluster;
}

Kmeans* kmeans(double[][] x, size_t k, int iter_max=30)
{
    assert(k < x.length);
    auto dim = x[0].length;
    auto codebook = uninitializedArray!(double[][])(k,dim);
    auto ind = randomSample(iota(x.length), k);
    // Codebook initialization
    for (size_t i = 0; i < k; i++) {
        auto p = ind.front;
        for (size_t j = 0; j < dim; j++) {
	    codebook[i][j] = x[p][j];
	}
	ind.popFront();
    }
    
    // Start iteration
    auto cluster = new size_t[x.length];
    for (int iter = 0; iter < iter_max; iter++) {
        for (int i = 0; i < x.length; i++) 
	   cluster[i] = nearest(codebook,x[i]);
	calc_centroid(codebook,x,cluster);
    }
    return new Kmeans(codebook, cluster);
}

/**

void main()
{
    auto rnd = Random(1234);
    auto x = uninitializedArray!(double[][])(30,2);
    for (size_t i = 0; i < x.length; i++) {
        x[i][0] = uniform(-1.0f, 1.0f, rnd);
        x[i][1] = uniform(-1.0f, 1.0f, rnd);
    }
    auto km = kmeans(x,3);
    for (size_t i = 0; i < x.length; i++)
      writefln!"%g %g %d"(x[i][0],x[i][1],km.cluster[i]);
 }
*/
