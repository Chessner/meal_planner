class Tuple<T1, T2> {
  T1 item1;
  T2 item2;

  Tuple(this.item1, this.item2);

  @override
  String toString() => '($item1, $item2)';
}