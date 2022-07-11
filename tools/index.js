const axios = require("axios");
const cheerio = require("cheerio");

async function getFF14VocationalSkill(url) {
  const { data, status } = await axios
    .post(url, { timeout: 1 * 60 * 1000 })
    .catch(console.error);
  if (status === 200) {
    const $ = cheerio.load(data);

    const vocationalSkillList = $("#tab-1 table td .item-name a");
    const skillInfoMap = new Map();
    for (const skill of vocationalSkillList) {
      const $skill = $(skill);
      const baseinfo = $skill.html();
      const skillName = baseinfo.split("<br>")[0];
      skillInfoMap.set(skillName, {
        id: $skill.attr("href").match(/:(\d+)/)[1],
      });
    }
    // console.log(skillInfoMap);
    for (const [skillName, si] of skillInfoMap) {
      const tooltipData = await getSkillTooltip(si.id);
      try {
        const $tooltip = cheerio.load(tooltipData.parse.text["*"]);
        const power = parseInt($tooltip.text().match(/威力[:：]?(\d+)/)[1]);
        const magicCost = parseInt(
          $tooltip.text().match(/消耗魔力[:：]?(\d+)/)[1]
        );
        skillInfoMap.set(
          skillName,
          Object.assign(si, {
            power,
            magicCost,
          })
        );
      } catch (e) {
        console.error(e);
      }
      // break;
    }
    // console.log(skillInfoMap);
    async function getSkillTooltip(id) {
      const { status, data } = await axios
        .get("https://ff14.huijiwiki.com/api.php", {
          params: {
            format: "json",
            action: "parse",
            disablelimitreport: true,
            prop: "text",
            title: "首页",
            smaxage: 86400,
            maxage: 86400,
            text: `{{ActionTooltip/Show|${id}}}`,
          },
        })
        .catch(console.error);
      if (status === 200) {
        return data;
      }
      return null;
    }
    return skillInfoMap;
  } else {
    console.log("未获取到html内容!");
  }
}
async function convertSkillData(url) {
  const res = await getFF14VocationalSkill(url);
  console.log(res);
}

convertSkillData(
  "https://ff14.huijiwiki.com/wiki/%E9%BB%91%E9%AD%94%E6%B3%95%E5%B8%88"
);
