/// for test
import std.stdio;
import std.datetime.stopwatch;
import std.datetime.systime;
import std.random;
import std.conv;
import std.array;
import quickdb;

void randinit(double[] x, ref Random rnd) {
  foreach (size_t i; 0..x.length)
    x[i] = uniform(-1.0f, 1.0f, rnd);
}

void main() {
  const size_t ndata = 100000;
  const size_t dimension = 10;
  uint seed = Clock.currTime().toUnixTime().to!uint();
  auto rnd = Random(seed);

  writeln("Preparing data");
  auto x = uninitializedArray!(double[][])(ndata,dimension);
  foreach (size_t i; 0..ndata) {
    randinit(x[i],rnd);
  }

  writeln("Clustering data");
  auto sw = StopWatch();
  sw.start();
  auto db = new QuickDB(x,100);
  sw.stop();
  writeln("Clustring took ",sw.peek()," seconds");
  sw.reset();
  auto y = new double[dimension];
  randinit(y,rnd);
  sw.start();
  auto n1 = db.nearest_naive(y);
  sw.stop();
  auto d1 = sw.peek();
  writeln("Naive ",d1," result ",n1);

  foreach (size_t nbest; 1..10) {
    sw.reset();
    sw.start();
    auto n2 = db.nearest(y,nbest);
    sw.stop();
    auto d2 = sw.peek();
    writeln(nbest," ", d2," result ",n2);
  }


 }
