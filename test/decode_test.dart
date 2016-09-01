import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

void main() {
  var connection = new PostgreSQLConnection("localhost", 5432, "dart_test", username: "dart", password: "dart");
  setUpAll(() async {
    print("opening");
    await connection.open();

    print("open");
    await connection.execute("CREATE TEMPORARY TABLE t (i int, s serial, bi bigint, bs bigserial, bl boolean, si smallint, t text, f real, d double precision, dt date, ts timestamp, tsz timestamptz)");
    await connection.execute("INSERT INTO t (i, bi, bl, si, t, f, d, dt, ts, tsz) VALUES (-2147483648, -9223372036854775808, TRUE, -32768, 'string', 10.0, 10.0, '1983-11-06', '1983-11-06 06:00:00.000000', '1983-11-06 06:00:00.000000')");
    await connection.execute("INSERT INTO t (i, bi, bl, si, t, f, d, dt, ts, tsz) VALUES (2147483647, 9223372036854775807, FALSE, 32767, 'a significantly longer string to the point where i doubt this actually matters', 10.25, 10.125, '2183-11-06', '2183-11-06 00:00:00.111111', '2183-11-06 00:00:00.999999')");
  });

  test("Fetch em", () async {
    var res = await connection.query("select * from t");

    var row1 = res[0];
    var row2 = res[1];
    expect(row1[0], equals(-2147483648));
    expect(row1[1], equals(1));
    expect(row1[2], equals(-9223372036854775808));
    expect(row1[3], equals(1));
    expect(row1[4], equals(true));
    expect(row1[5], equals(-32768));
    expect(row1[6], equals("string"));
    expect(row1[7] is double, true);
    expect(row1[7], equals(10.0));
    expect(row1[8] is double, true);
    expect(row1[8], equals(10.0));
    expect(row1[9], equals(new DateTime(1983, 11, 6)));
    expect(row1[10], equals(new DateTime(1983, 11, 6, 6)));
    expect(row1[11], equals(new DateTime(1983, 11, 6, 6)));

    expect(row2[0], equals(2147483647));
    expect(row2[1], equals(2));
    expect(row2[2], equals(9223372036854775807));
    expect(row2[3], equals(2));
    expect(row2[4], equals(false));
    expect(row2[5], equals(32767));
    expect(row2[6], equals("a significantly longer string to the point where i doubt this actually matters"));
    expect(row2[7] is double, true);
    expect(row2[7], equals(10.25));
    expect(row2[8] is double, true);
    expect(row2[8], equals(10.125));
    expect(row2[9], equals(new DateTime(2183, 11, 6)));
    expect(row2[10], equals(new DateTime(2183, 11, 6, 0, 0, 0, 111, 111)));
    expect(row2[11], equals(new DateTime(2183, 11, 6, 0, 0, 0, 999, 999)));
  });

  test("Timezone concerns", () {

  });
}