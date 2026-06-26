"use client";

import { Card, Notice } from "./ui";

const contents = [
  {
    title: "通常、上下の歯は離れている",
    body: "安静時は唇を軽く閉じ、上下の歯の間には少しすき間がある状態が目安です。"
  },
  {
    title: "食いしばりは無自覚で起こりやすい",
    body: "集中、緊張、スマホ操作、作業中などに、気づかないまま歯が触れていることがあります。"
  },
  {
    title: "TCH改善は気づく回数を増やすことが重要",
    body: "完全に防ぐよりも、触れていることに気づき、すぐ力を抜く回数を増やします。"
  },
  {
    title: "夜間の食いしばりは完全制御が難しい",
    body: "睡眠中は自分でコントロールしにくいため、日中の癖から整えるのが現実的です。"
  },
  {
    title: "日中の歯の接触時間を減らすことが第一歩",
    body: "短いチェックを重ねることで、顎や首肩への負担を減らすきっかけを作ります。"
  },
  {
    title: "顎が痛い場合は歯科医に相談",
    body: "痛み、口の開けづらさ、歯の違和感が強い場合は、セルフケアだけで判断しないでください。"
  }
];

export function LearnScreen() {
  return (
    <div className="space-y-5">
      <Card>
        <p className="text-sm font-bold text-calm-700">教育コンテンツ</p>
        <h2 className="mt-2 text-2xl font-bold text-slate-950">短く知る</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          不安を増やすためではなく、気づきやすくするための知識です。
        </p>
      </Card>

      <div className="space-y-3">
        {contents.map((content) => (
          <Card key={content.title}>
            <h3 className="text-base font-bold text-slate-950">{content.title}</h3>
            <p className="mt-2 text-sm leading-6 text-slate-500">{content.body}</p>
          </Card>
        ))}
      </div>

      <PhotoGuide />
      <Notice />
    </div>
  );
}

function PhotoGuide() {
  const poses = ["正面", "右45度", "左45度", "横顔"];

  return (
    <Card>
      <p className="text-sm font-bold text-calm-700">月1写真記録</p>
      <h3 className="mt-2 text-lg font-bold text-slate-950">撮影ガイド</h3>
      <p className="mt-2 text-sm leading-6 text-slate-500">
        画像保存はMVPでは未実装です。同じ条件で撮るためのガイドとして使います。
      </p>
      <div className="mt-4 grid grid-cols-2 gap-3">
        {poses.map((pose) => (
          <div key={pose} className="rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-4 text-center">
            <div className="mx-auto h-20 w-14 rounded-full border-2 border-calm-500 bg-white" />
            <p className="mt-3 text-sm font-bold text-slate-700">{pose}</p>
          </div>
        ))}
      </div>
      <p className="mt-4 rounded-2xl bg-skycare-50 p-4 text-sm leading-6 text-skycare-700">
        同じ照明・同じ距離・無表情で撮影してください。
      </p>
    </Card>
  );
}
